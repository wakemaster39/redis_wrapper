require 'redis_wrapper/redis_wrapper'
require 'redis'
describe RedisWrapper::RedisWrapper do
  describe '#get_options' do
    before do
      @wrapper = RedisWrapper::RedisWrapper.new()
    end
    it 'should return nil if last object is not a hash' do
      @wrapper.send(:get_options, [],{},[]).should eq(nil)
    end
    it 'should return nil if object is a hash without a proper key' do
      @wrapper.send(:get_options, [],{},{}).should eq(nil)
    end
    it 'should return args without last hash and the hash if contains proper key' do
      @wrapper.send(:get_options, [],{},{:expire_in => 1}).should eq([{:expire_in => 1}, [[], {}]])
    end
  end

  describe '#get_key' do
    before do
      @wrapper = RedisWrapper::RedisWrapper.new()
      @key = "test"
      @other =  [[1,2,3],{:expire_in=>1}]
    end
    it 'should return nil and args if first object is not a string' do
      @wrapper.send(:get_key, *@other).should eq([nil,@other])
    end
    it 'should return string and args without string if first object is a string' do
      @wrapper.send(:get_key, @key, *@other).should eq([@key,@other])
    end
  end

  describe '#handle' do
    before do
      @wrapper = RedisWrapper::RedisWrapper.new()
      @args = [[1,2,3],{:test=>1}]
    end
    it 'should return an array of string independent of what was passed' do
      @wrapper.send(:handle,*@args).map{|u| u.class == String}.uniq.should eq([true])
    end
  end

  describe '#method_missing' do
    before do
      @wrapper =  RedisWrapper::RedisWrapper.new()
      @redis = Redis.new()
    end
    it 'should set a TTL if options hash contains a :expire_in key' do
      @wrapper.set "test", "test", :expire_in => 100
      @redis.ttl("test").should_not eq(-1)
    end
    it 'should return response from server' do
      @wrapper.set("test", "test").should eq(@redis.set("test", "test"))
    end
    it 'should have no expiry if none was passed or previously set' do
      @redis.ttl("test1").should eq(-1)
      @wrapper.set("test1", "test")
      @redis.ttl("test1").should eq(-1)
    end
  end
end