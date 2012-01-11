require "redis"

module RedisWrapper
  class RedisWrapper
    FLAG_MARSHALLED = "0x1"
    FLAG_COMPRESSED = "0x2"
    #DEFAULT_COMPRESS_LIMIT = 16.kilobytes
    
    def initialize(value, options = {})
      @compressed = false
      @expires_in = options[:expires_in]
      @expires_in = @expires_in.to_f if @expires_in
      @created_at = Time.now.to_f
      @flags = {}
      # if value.nil?
        # @value = nil
      # else
        # flags = flag_extraction
        # @value = Marshal.dump(value) if
        # if should_compress?(@value, options)
          # @value = Zlib::Deflate.deflate(@value)
          # @compressed = true
        # end
      # end
    end  
    
    def flag_extraction
      puts @value
      if @value
        pflag = @value[0..-4]
        puts pflag
        flagged = false
        if pflag == FLAG_MARSHALLED
          @flags[:marshalled] = true
          value = value.slice[0..-4]
          flagged = true
        elsif pflag == FLAG_COMPRESSED
          @flags[:compressed] = true
          value = value.slice[0..-4]
          flagged = true
        end
        flags_extraction if flagged
        flags
      end
    end
    
    # Get the raw value. This value may be serialized and compressed.
    def raw_value
      @value
    end
    
    def value
      # If the original value was exactly false @value is still true because
      # it is marshalled and eventually compressed. Both operations yield
      # strings.
      if @value
        Marshal.load(compressed? ? Zlib::Inflate.inflate(@value) : @value)
      end
    end
  
    def compressed?
      @compressed
    end
    
    def size
      if @value.nil?
        0
      else
        @value.bytesize
      end
    end
  
    private
      def should_compress?(serialized_value, options)
        unless options[:raw]
          compress_threshold = options[:compress_threshold] || DEFAULT_COMPRESS_LIMIT
          return true if serialized_value.size >= compress_threshold
        end
        false
      end
  end
end
