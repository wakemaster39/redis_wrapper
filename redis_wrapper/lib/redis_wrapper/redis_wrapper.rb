module RedisWrapper
  class RedisWrapper
    attr_accessor :namespace
    # The following table defines how input parameters and result
    # values should be modified for the namespace along with Object compression.
    # Thanks is due to defunkt and his gem, https://github.com/defunkt/redis-namespace as
    # inspiration on how to solve this problem.
    #
    # COMMANDS is a hash. Each key is the name of a command and each
    # value is a hash itself. The namespace key holds an 2 value array, determining the process of
    # how to merge on the namespace. The options key, holds a hash that is merged onto the other options passed
    # This insures that some commands like AUTH, are enforced to be raw true so Entry doesn't alter the command.
    #
    # The first element in the value array describes how to modify the
    # arguments passed. It can be one of:
    #
    # nil
    # Do nothing.
    # :first
    # Add the namespace to the first argument passed, e.g.
    # GET key => GET namespace:key
    # :all
    # Add the namespace to all arguments passed, e.g.
    # MGET key1 key2 => MGET namespace:key1 namespace:key2
    # :exclude_first
    # Add the namespace to all arguments but the first, e.g.
    # :exclude_last
    # Add the namespace to all arguments but the last, e.g.
    # BLPOP key1 key2 timeout =>
    # BLPOP namespace:key1 namespace:key2 timeout
    # :exclude_options
    # Add the namespace to all arguments, except the last argument,
    # if the last argument is a hash of options.
    # ZUNIONSTORE key1 2 key2 key3 WEIGHTS 2 1 =>
    # ZUNIONSTORE namespace:key1 2 namespace:key2 namespace:key3 WEIGHTS 2 1
    # :alternate
    # Add the namespace to every other argument, e.g.
    # MSET key1 value1 key2 value2 =>
    # MSET namespace:key1 value1 namespace:key2 value2
    #
    # The second element in the value array describes how to modify
    # the return value of the Redis call. It can be one of:
    #
    # nil
    # Do nothing.
    # :all
    # Add the namespace to all elements returned, e.g.
    # key1 key2 => namespace:key1 namespace:key2
    COMMANDS = {
      :auth => {:namespace=>[],:options=>{:raw=>true}},
      :bgrewriteaof => {:namespace=>[], :options=>{}},
      :bgsave => {:namespace=>[], :options=>{}},
      :blpop => {:namespace=>[ :exclude_last, :first ], :options=>{}},
      :brpop => {:namespace=>[ :exclude_last ], :options=>{}},
      :dbsize => {:namespace=>[], :options=>{}},
      :debug => {:namespace=>[ :exclude_first ], :options=>{}},
      :decr => {:namespace=>[ :first ], :options=>{}},
      :decrby => {:namespace=>[ :first ], :options=>{}},
      :del => {:namespace=>[ :all ], :options=>{}},
      :exists => {:namespace=>[ :first ], :options=>{}},
      :expire => {:namespace=>[ :first ], :options=>{}},
      :expireat => {:namespace=>[ :first ], :options=>{}},
      :flushall => {:namespace=>[], :options=>{}},
      :flushdb => {:namespace=>[], :options=>{}},
      :get => {:namespace=>[ :first ], :options=>{}},
      :getset => {:namespace=>[ :first ], :options=>{}},
      :hset => {:namespace=>[ :first ], :options=>{}},
      :hsetnx => {:namespace=>[ :first ], :options=>{}},
      :hget => {:namespace=>[ :first ], :options=>{}},
      :hincrby => {:namespace=>[ :first ], :options=>{}},
      :hmget => {:namespace=>[ :first ], :options=>{}},
      :hmset => {:namespace=>[ :first ], :options=>{}},
      :hdel => {:namespace=>[ :first ], :options=>{}},
      :hexists => {:namespace=>[ :first ], :options=>{}},
      :hlen => {:namespace=>[ :first ], :options=>{}},
      :hkeys => {:namespace=>[ :first ], :options=>{}},
      :hvals => {:namespace=>[ :first ], :options=>{}},
      :hgetall => {:namespace=>[ :first ], :options=>{}},
      :incr => {:namespace=>[ :first ], :options=>{}},
      :incrby => {:namespace=>[ :first ], :options=>{}},
      :info => {:namespace=>[], :options=>{}},
      :keys => {:namespace=>[ :first, :all ], :options=>{}},
      :lastsave => {:namespace=>[], :options=>{}},
      :lindex => {:namespace=>[ :first ], :options=>{}},
      :llen => {:namespace=>[ :first ], :options=>{}},
      :lpop => {:namespace=>[ :first ], :options=>{}},
      :lpush => {:namespace=>[ :first ], :options=>{}},
      :lrange => {:namespace=>[ :first ], :options=>{}},
      :lrem => {:namespace=>[ :first ], :options=>{}},
      :lset => {:namespace=>[ :first ], :options=>{}},
      :ltrim => {:namespace=>[ :first ], :options=>{}},
      :mapped_hmset => {:namespace=>[ :first ], :options=>{}},
      :mapped_mget => {:namespace=>[ :all, :all ], :options=>{}},
      :mget => {:namespace=>[ :all ], :options=>{}},
      #:monitor => {:namespace=>[ :monitor ], :options=>{}},
      :move => {:namespace=>[ :first ], :options=>{}},
      :mset => {:namespace=>[ :alternate ], :options=>{}},
      :msetnx => {:namespace=>[ :alternate ], :options=>{}},
      :psubscribe => {:namespace=>[ :all ], :options=>{}},
      :publish => {:namespace=>[ :first ], :options=>{}},
      :punsubscribe => {:namespace=>[ :all ], :options=>{}},
      :quit => {:namespace=>[], :options=>{}},
      :randomkey => {:namespace=>[], :options=>{}},
      :rename => {:namespace=>[ :all ], :options=>{}},
      :renamenx => {:namespace=>[ :all ], :options=>{}},
      :rpop => {:namespace=>[ :first ], :options=>{}},
      :rpoplpush => {:namespace=>[ :all ], :options=>{}},
      :rpush => {:namespace=>[ :first ], :options=>{}},
      :sadd => {:namespace=>[ :first ], :options=>{}},
      :save => {:namespace=>[], :options=>{}},
      :scard => {:namespace=>[ :first ], :options=>{}},
      :sdiff => {:namespace=>[ :all ], :options=>{}},
      :sdiffstore => {:namespace=>[ :all ], :options=>{}},
      :select => {:namespace=>[], :options=>{}},
      :set => {:namespace=>[ :first ], :options=>{}},
      :setex => {:namespace=>[ :first ], :options=>{}},
      :setnx => {:namespace=>[ :first ], :options=>{}},
      :shutdown => {:namespace=>[], :options=>{}},
      :sinter => {:namespace=>[:all], :options=>{}},
      :sinterstore => {:namespace=>[:all], :options=>{}},
      :sismember => {:namespace=>[:first], :options=>{}},
      :slaveof => {:namespace=>[], :options=>{}},
      :smembers => {:namespace=>[:first], :options=>{}},
      :smove => {:namespace=>[:exclude_last], :options=>{}},
      #:sort => {:namespace=>[:sort], :options=>{}},
      :spop => {:namespace=>[:first], :options=>{}},
      :srandmember => {:namespace=>[:first], :options=>{}},
      :srem => {:namespace=>[:first], :options=>{}},
      :subscribe => {:namespace=>[:all], :options=>{}},
      :sunion => {:namespace=>[:all], :options=>{}},
      :sunionstore => {:namespace=>[:all], :options=>{}},
      :ttl => {:namespace=>[:first], :options=>{}},
      :type => {:namespace=>[:first], :options=>{}},
      :unsubscribe => {:namespace=>[:all], :options=>{}},
      :zadd => {:namespace=>[:first], :options=>{}},
      :zcard => {:namespace=>[:first], :options=>{}},
      :zcount => {:namespace=>[:first], :options=>{}},
      :zincrby => {:namespace=>[:first], :options=>{}},
      :zinterstore => {:namespace=>[:exclude_options],:options=>{}},
      :zrange => {:namespace=>[:first], :options=>{}},
      :zrangebyscore => {:namespace=>[:first], :options=>{}},
      :zrank => {:namespace=>[:first], :options=>{}},
      :zrem => {:namespace=>[:first], :options=>{}},
      :zremrangebyrank => {:namespace=>[:first], :options=>{}},
      :zremrangebyscore => {:namespace=>[:first], :options=>{}},
      :zrevrange => {:namespace=>[:first], :options=>{}},
      :zrevrangebyscore => {:namespace=>[:first], :options=>{}},
      :zrevrank => {:namespace=>[:first], :options=>{}},
      :zscore => {:namespace=>[:first], :options=>{}},
      :zunionstore => {:namespace=>[:exclude_options], :options=>{}},
      :[] => {:namespace=>[:first], :options=>{}},
      :[]= => {:namespace=>[:first], :options=>{}}
    }

    def initialize(options={})
      @namespace = options[:namespace]
      @client =  options[:redis] || Redis.current
    end

    def method_missing(method, *args, &block)
      if @client.respond_to? method
        @options, args = get_options(*args) || [{}, args]
        @options.merge(COMMANDS[method.to_sym][:options])
        args = handle(method, *args)
        result = @client.send(method, *args, &block)
        @client.send(:expire, args[0], @options[:expire_in].to_i) if @options[:expire_in] && args[0]
        extract(method, result)
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

      def handle(method, *args)
        format = COMMANDS[method.to_sym][:namespace]
        return args if format.nil?
        case format[0]
        when :first
          if args[0]
            first = args.shift
            first = namespace(first) if first
            args = args.map{|arg| prepare(arg)}
            args.unshift(first)
          end
          args
        when :all
          namespace(args)
        when :exclude_first
          first = args.shift
          args = namespace(args)
          args.unshift(first) if first
        when :exclude_last
          last = args.last.kind_of?(Hash) ? args.pop : nil
          args = namespace(args)
          args.push(last) if !last.nil?
        when :alternate
          args.each_with_index do |arg,i|
            case i.even?
              when true
                arg[i] = namespace(arg[i])
              when false
                arg[i] = prepare(arg[i])
            end
          end
        when :sort
          #TODO solve this problem
        end
        args
      end

      def prepare(value)
        Entry.new(value, @options).prepared_result if value
      end

      def namespace(args)
        return args unless args && @namespace
        case args
        when Array
          args.map {|k| namespace(k)}
        when Hash
          Hash[*args.map {|k, v| [namespace(k), prepare(v) ]}.flatten]
        else
          "#{@namespace}:#{args}"
        end
      end

      def rm_namespace(args)
        return args unless args && @namespace
        case args.class
        when Array
          args.map {|k| rem_namespace(k)}
        when Hash
          Hash[*args.map {|k, v| [ rem_namespace(k), prepare(v) ]}.flatten]
        else
          args.to_s.gsub /^#{@namespace}:/, ""
        end
      end

      def extract(method, args)
        format = COMMANDS[method.to_sym]
        return args if format.nil?
        case format[1]
          when :all
            rm_namespace(args)
          when nil
            if args.class == String
              Entry.new(args, @options).extracted_result
            else
              args.map{|arg| Entry.new(arg, @options).extracted_result}
            end
        end
      end
  end
end