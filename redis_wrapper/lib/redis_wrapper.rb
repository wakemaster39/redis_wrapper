require "redis"
require "redis_wrapper/version"

module RedisWrapper
  autoload :RedisWrapper, File.join(File.dirname(__FILE__), "redis_wrapper", "redis_wrapper")
  autoload :Entry, File.join(File.dirname(__FILE__), "redis_wrapper", "entry")
end
