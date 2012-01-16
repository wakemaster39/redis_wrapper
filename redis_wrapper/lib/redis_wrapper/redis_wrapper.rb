module RedisWrapper
  class RedisWrapper
    def initialize(options={})
      @client = Redis.new(options)
    end
    def method_missing(method, *args, &block)
      if @client.respond_to? method
        options, args = get_options(*args) || [{}, args]
        key, args = get_key(*args)
        args = handle(*args)
        args = [key] + args if args && key
        result = Entry.new(@client.send(method, *args, &block), options).extracted_result
        @client.send(:expire, key, options[:expire_in].to_i) if options[:expire_in]
        result
      else
        raise NameError, :message=> "method #{method} is not defined"
      end
    end
    
    private
      def get_options(*args)
        if args.last.kind_of?(Hash)
          if Entry.option_keys.map{|key| args.last.keys.include?(key)}.compact.include?(true)
            return args.pop, args
          end
        end
      end
      
      def get_key(*args)
        args.first.kind_of?(String) ? [args.shift, args] : [nil, args]
      end
      
      def handle(*args)
        args.map{|u| Entry.new(u).prepared_result} if args
      end
  end
end