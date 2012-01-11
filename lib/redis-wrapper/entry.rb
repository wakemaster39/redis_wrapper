module RedisWrapper
  class Entry
    attr_accessor :flags, :value
    FLAG_MARSHALED = "0x1"
    FLAG_COMPRESSED = "0x2"
    DEFAULT_COMPRESS_LIMIT = 16 * 1024 #16 kilobytes
    
    def initialize(value, options = {})
      @flags = options[:flags] || {}
      @value = value
      @options = options
      flag_extraction if @value.class == String
      @value = compress(marshal(@value)) if @flags == {} && !options[:raw]
    end
    
    def result
      @value = demarshal(decompress(@value))
    end
    
    def demarshal(val)
      if marshaled?
        @flags[:marshaled] = false
        return Marshal.load(val)
      end
      val
    end
    
    def decompress(val)
      if compressed?
        @flags[:compressed] = false
        return Zlib::Inflate.inflate(val)
      end
      val
    end
    
    def compress(val)
      if should_compress?
        @flags[:compressed] = true
        return Zlib::Deflate.deflate(val)
      end
      val
    end
    
    def marshal(val)
      if val
        @flags[:marshaled] = true
        Marshal.dump(val)
      end
    end
    
    def flag_extraction
      if @value
        pflag = @value.slice(@value.length-3..@value.length)
        if pflag == FLAG_MARSHALED
          @flags[:marshaled] = true
          @value = @value.slice(0..-4)
          flag_extraction
        elsif pflag == FLAG_COMPRESSED
          @flags[:compressed] = true
          @value = @value.slice(0..-4)
          flag_extraction
        end
      end
    end
    
    private
      def compressed?
        @flags[:compressed] == true
      end
      def marshaled?
        @flags[:marshaled] == true
      end
      def should_compress?
        unless @options[:raw] || @value.nil?
          compression_threshold = @options[:compression_threshold] || DEFAULT_COMPRESS_LIMIT
          return true if @value.size >= compression_threshold
        end
        false
      end
  end
end