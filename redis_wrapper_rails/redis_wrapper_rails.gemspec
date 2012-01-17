lib = File.expand_path('../../redis_wrapper/lib/', __FILE__)

$:.unshift(lib) unless $:.include?(lib)

require 'redis_wrapper/version'

Gem::Specification.new do |s|
  s.name = "redis_wrapper_rails"
  s.version = RedisWrapper::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["wakemaster39"]
  s.date = "2012-01-17"
  s.description = "Provides rails specific functionality for redis-wrapper. Display's key and method calls to redis along with overall access times in the controller logs.'"
  s.email = "wakemaster39@gmail.com"
  s.extra_rdoc_files = [
    "README.md"
  ]

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.homepage = "http://github.com/wakemaster39/redis-wrapper"
  s.licenses = ["MIT"]
  s.rubygems_version = "1.8.10"
  s.summary = "Rails specific bindings for redis_wrapper"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis_wrapper>, RedisWrapper::VERSION)
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<redis_wrapper>, RedisWrapper::VERSION)
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<redis_wrapper>, RedisWrapper::VERSION)
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

