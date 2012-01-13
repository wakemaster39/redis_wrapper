require 'redis-wrapper/entry.rb'
require 'zlib'

describe RedisWrapper::Entry do
  describe '#flag_extraction' do 
    context 'raw object' do
      before do
        @teststring = "teststring"
        @wrapper = RedisWrapper::Entry.new(@teststring,:raw=>true)
      end
      it 'should extract no flags' do
        @wrapper.flag_extraction
        @wrapper.flags.should eq({})
      end
      it 'should not alter the string' do
        @wrapper.flag_extraction
        @wrapper.value.should eq(@teststring)
      end
    end
    context 'marshaled object' do
      before do
        @teststring = "teststring0x1"
        @wrapper = RedisWrapper::Entry.new(@teststring)
      end
      it 'should determine object is marshaled' do
        @wrapper.flags.should include(:marshaled=>true) #include hash key
      end
      it 'should not need deflating' do
        @wrapper.flags.should_not include(:compressed=>true) #include hash key
      end
      it 'should not pick flag if string contains flag not at end' do
        @wrapper = RedisWrapper::Entry.new("0x10x10x10x1test",:raw=>true)
        @wrapper.flag_extraction
        @wrapper.flags.should_not include(:marshaled=>true)
      end
      it 'should not matter if double flagged' do
        @wrapper = RedisWrapper::Entry.new("teststring0x10x1")
        @wrapper.flags.should include(:marshaled=>true)
        @wrapper.flags.should_not include(:compressed=>true)
      end
      it 'should remove the flag' do
        @wrapper.value.should eq(@teststring.slice(0..-4))
      end
    end
    context 'compressed object' do
      before do
        @teststring = "teststring0x2"
        @wrapper = RedisWrapper::Entry.new(@teststring)
      end
      it 'should determine object is compressed' do
        @wrapper.flags.should include(:compressed=>true) #include hash key
      end
      it 'should not need to be marshal dumped' do
        @wrapper.flags.should_not include(:marshaled=>true) #include hash key
      end
      it 'should not pick flag if string contains flag not at end' do
        @wrapper = RedisWrapper::Entry.new("0x20x20x20x2test")
        @wrapper.flags.should_not include(:compressed=>true)
      end
      it 'should not matter if double flagged' do
        @wrapper = RedisWrapper::Entry.new("teststring0x20x2")
        @wrapper.flags.should_not include(:marshaled=>true)
        @wrapper.flags.should include(:compressed=>true)
      end
      it 'should remove the flag' do
        @wrapper.value.should eq(@teststring.slice(0..-4))
      end
    end
    context 'marshaled and compressed object' do
      before do
        @teststring = "teststring0x10x2"
        @wrapper = RedisWrapper::Entry.new(@teststring)
      end
      it 'should determine value is compressed and marshaled' do
        @wrapper.flag_extraction
        @wrapper.flags.should include(:compressed=>true,:marshaled=>true)
      end
      it 'should be based on order of flags' do
        @wrapper.value = "teststring0x20x1"
        @wrapper.flag_extraction
        @wrapper.flags.should include(:compressed=>true,:marshaled=>true)
      end
      it 'should remove the flags' do
        @wrapper.flag_extraction
        @wrapper.value.should eq(@teststring.slice(0..-7))
      end
    end
  end
  
  describe '#compressed?' do
    before do
      @wrapper = RedisWrapper::Entry.new(nil)
    end
    it 'should return true if compression flag true' do
      @wrapper.flags = {:compressed=>true}
      @wrapper.send(:compressed?).should eq(true)
    end
    it 'should return false if anything else' do
      @wrapper.send(:compressed?).should eq(false)
      @wrapper.flags = {:compressed=>"true"}
      @wrapper.send(:compressed?).should eq(false)
    end
  end
  describe '#marshaled?' do
    before do
      @wrapper = RedisWrapper::Entry.new(nil)
    end
    it 'should return true if compression flag true' do
      @wrapper.flags = {:marshaled=>true}
      @wrapper.send(:marshaled?).should eq(true)
    end
    it 'should return false if anything else' do
      @wrapper.send(:marshaled?).should eq(false)
      @wrapper.flags = {:compressed=>"true"}
      @wrapper.send(:marshaled?).should eq(false)
    end
  end
  
  describe '#decompress' do
    before do
      @wrapper = RedisWrapper::Entry.new(nil)
      @raw = "teststring"
      @wrapper.value = Zlib::Deflate.deflate(@raw)
      @wrapper.flags[:compressed] = true
    end
    it 'should decompress a compressed object' do
      result = @wrapper.decompress(@wrapper.value)
      result.should eq(@raw)
    end
    it 'should return original value if compression flag is not true' do
      @wrapper.flags[:compressed] = false
      @wrapper.decompress("test").should eq("test")
    end
    it 'should return error if value is not compressed' do
      lambda {@wrapper.decompress("test")}.should raise_error
    end
    it 'should unset flag' do
      @wrapper.decompress(@wrapper.value)
      @wrapper.flags[:compressed].should_not eq(true)
    end
  end
  
  describe '#demarshal' do
    before do
      @wrapper = RedisWrapper::Entry.new(nil)
      @raw = "teststring"
      @wrapper.value = Marshal.dump(@raw)
      @wrapper.flags[:marshaled] = true
    end
    it 'should demarshal a marshaled object' do
      result = @wrapper.demarshal(@wrapper.value)
      result.should eq(@raw)
    end
    it 'should return original value if marshaled flag is not true' do
      @wrapper.flags[:marshaled] = false
      @wrapper.demarshal("test").should eq("test")
    end
    it 'should return error if value is not marshaled' do
      lambda {@wrapper.demarshal("test")}.should raise_error
    end
    it 'should unset flag' do
      @wrapper.demarshal(@wrapper.value)
      @wrapper.flags[:marshaled].should_not eq(true)
    end
  end
  
  describe '#result' do
    before do
      @wrapper = RedisWrapper::Entry.new(nil)
    end
    context 'should return original value if' do
      it 'marshaled' do
        @wrapper.value = Marshal.dump(Array.new)
        @wrapper.flags[:marshaled] = true
        @wrapper.result.should eq(Array.new)
      end
      it 'compressed' do
        @wrapper.value = Zlib::Deflate.deflate("test")
        @wrapper.flags[:compressed] = true
        @wrapper.result.should eq("test")
      end
      it 'compressed and marshaled' do
        @wrapper.value = Zlib::Deflate.deflate(Marshal.dump(Array.new))
        @wrapper.flags = {:compressed=>true,:marshaled=>true}
        @wrapper.result.should eq(Array.new)
      end
    end
  end
  
  describe '#should_compress?' do
    before do
      @wrapper = RedisWrapper::Entry.new(nil)
      @teststring = (0..10000).map{|u| u*u}.to_s
    end
    it 'should return false if :raw is set to true even if over threshold' do
      @wrapper = RedisWrapper::Entry.new(nil,{:raw=>true})
      @wrapper.value = @teststring
      @wrapper.send(:should_compress?).should eq(false)
    end
    it 'should return true if over threshold without bypass' do
      @wrapper.value = @teststring
      @wrapper.send(:should_compress?).should eq(true)
    end
    it 'should accept a change in thershold in object creation' do
      @wrapper = RedisWrapper::Entry.new(nil,{:compression_threshold=>100000})
      @wrapper.value = @teststring
      @wrapper.send(:should_compress?).should eq(false)
    end
    it 'should return true if greater than threshold' do
      @wrapper.value = @teststring
      @wrapper.send(:should_compress?).should eq(true)
    end
    it 'should not compress nil values' do
      @wrapper.send(:should_compress?).should eq(false)
    end
  end
  
  describe '#marshal' do
    before do
      @obj = Array.new
      @wrapper = RedisWrapper::Entry.new(@obj)
    end
    it 'should marshal an object' do
      @wrapper.marshal(@obj).should eq(Marshal.dump(@obj))
    end
    it 'should set marshal flag to true' do
      @wrapper.marshal(@obj)
      @wrapper.flags[:marshaled].should eq(true)
    end
  end
  
  describe '#compress' do
    before do
      @wrapper = RedisWrapper::Entry.new("teststring1",:compression_threshold=>10)
    end
    it 'should compress object if above threshold' do
      @wrapper.compress(@wrapper.value).should eq(Zlib::Deflate.deflate(@wrapper.value))
    end
    it "shouldn't compress if below threshold" do
      @wrapper = RedisWrapper::Entry.new("teststring1")
      @wrapper.compress(@wrapper.value).should eq(@wrapper.value)
    end
    it "should set compression flag true" do
      @wrapper.compress(@wrapper.value)
      @wrapper.flags[:compressed].should eq(true)
    end
  end
  
  describe '#new' do
    context 'passed a string' do
      before do
        @teststring = "teststring"
      end
      it 'should extract flags if passed an ecoded string' do
        @wrapper = RedisWrapper::Entry.new(@teststring + "0x10x2")
        @wrapper.flags.should include(:compressed=>true, :marshaled=>true)
        @wrapper.value.should eq(@teststring)
      end
      it 'should marshal and compress if no flags extracted and :raw is false' do
        @wrapper = RedisWrapper::Entry.new(@teststring, :compression_threshold=>2)
        @wrapper.flags.should include(:compressed=>true, :marshaled=>true)
        @wrapper.value.should eq(Zlib::Deflate.deflate(Marshal.dump(@teststring)))
      end
      it 'should set no flags if :raw true and take no action' do
        @wrapper = RedisWrapper::Entry.new(@teststring, :compression_threshold=>2, :raw=>true)
        @wrapper.value.should eq(@teststring)
        @wrapper.flags.should eq({})
      end
    end
    context 'passed an object' do
      before do
        @obj = Array.new
        @options = {:compression_threshold=>0}
      end
      it 'should marshal and compress objects' do
        @wrapper = RedisWrapper::Entry.new(@obj,@options)
        @wrapper.value.should eq(Zlib::Deflate.deflate(Marshal.dump(@obj)))
        @wrapper.flags.should eq(:compressed=>true,:marshaled=>true)
      end
      it 'should respect the raw flag' do
        @wrapper = RedisWrapper::Entry.new(@obj,@options.merge(:raw=>true))
        @wrapper.value.should eq(@obj)
        @wrapper.flags.should eq({})
      end
    end
    context 'passed nil' do
      before do
        @wrapper = RedisWrapper::Entry.new(nil,:compression_threshold=>2)
      end
      it 'should skip compression and marshalling' do
        @wrapper.flags.should eq({})
      end
      it 'should leave object alone' do
        @wrapper.value.should eq(nil)
      end
    end
    context 'options should' do
      it 'allow manual setting of flags' do
        @wrapper = RedisWrapper::Entry.new(nil,:flags=>{:compressed=>true})
        @wrapper.flags.should eq(:compressed=>true)
      end
    end
  end
  
  describe "#result" do
    before do
      @options= {:compression_threshold=>0}
      @obj = Array.new
      @wrapper = RedisWrapper::Entry.new(@obj,@options)
    end
    it 'should decompress and demarshal value' do
      @wrapper.result.should eq(@obj)
    end
    it 'should clear flags' do
      @wrapper.flags.should eq(:compressed=>true,:marshaled=>true)
      @wrapper.flags.should eq({})
    end
    it 'should change stored value' do
      @wrapper.value.should_not eq(@obj)
      @wrapper.result
      @wrapper.value.should eq(@bj)
    end
  end
end