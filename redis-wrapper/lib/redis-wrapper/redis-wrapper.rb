module RedisWrapper
  require 'redis'
  class RedisWrapper
    def initialize(options={})
      @client = Redis.new(options)
    end
    def method_missing(method, *args, &block)
      if @client.respond_to? method
        options = get_options(*args) || {}
        Entry.new(@client.send(method, *args #need to handle *args, find a way to determine what needs to be Entry.new()
                                             #read redis API, suspect anything with more than a key should be zipped.
        , &block), options).result
        
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
  end
end