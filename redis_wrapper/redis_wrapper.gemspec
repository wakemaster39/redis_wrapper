require './lib/redis_wrapper/version'

Gem::Specification.new do |s|
  s.name = "redis_wrapper"
  s.version = RedisWrapper::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["wakemaster39"]
  s.date = "2012-01-17"
  s.description = "A high level wrapper around the redis-rb gem and API. Designed to be a drop in replacement for Redis class while handling object marshaling and compression, setting key expiries, and namespacing your keys"
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
  s.summary = "High level wrapper around redis API"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>, ["~>2.2.1"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<redis>, ["~>2.2.1"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<redis>, ["~>2.2.1"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

