require "redis"

module RedisWrapper
  autoload :RedisWrapper, File.join(File.dirname(__FILE__), "redis-wrapper", "redis-wrapper")
  autoload :Entry, File.join(File.dirname(__FILE__), "redis-wrapper", "entry")
end