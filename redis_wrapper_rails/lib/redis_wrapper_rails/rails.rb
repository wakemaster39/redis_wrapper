require 'redis_wrapper'
#require "redis_wrapper_rails/version"

module RedisWrapper
  module Rails
    autoload :RedisInstrumentation, File.join(File.dirname(__FILE__), "rails" ,'redis_instrumentation')
    # Your code goes here...
  end
end