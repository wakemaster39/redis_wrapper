module RedisWrapper
  require 'redis'
  class RedisWrapper
    def initialize(options={})
      @client = Redis.new(options)
    end
    def method_missing(method, *args, &block)
      if @client.respond_to? method
        options = get_options(args) || {}
        key = get_key(args)
        handle(args)
        args = [key] + args if args
        Entry.new(@client.send(method, args, &block), options).result
      else
        raise NameError, :message=> "method #{method} is not defined"
      end
    end
    
    private
      def get_options(*args)
        if args.last.kind_of?(Hash) 
          if Entry.option_keys.map{|key| args.last.keys.include?(key)}.compact.include?(true)
            args.pop
          end
        end
      end
      
      def get_key(*args)
        args.first.kind_of?(String) ? args.shift : nil
      end
      
      def handle(*args)
        args.each{|u| u = Entry.new(u).value} if args
      end
  end
end