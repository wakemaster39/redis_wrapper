# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis-wrapper/version"

Gem::Specification.new do |s|
  s.name        = "redis-wrapper"
  s.version     = RedisWrapper::VERSION
  s.authors     = ["wakemaster39"]
  s.email       = ["wakemaster39@gmail.com"]
  s.homepage    = "https://github.com/wakemaster39/redis-wrapper"
  s.summary     = %q{High level wrapper around redis-rb}
  s.description = %q{High level wrapper around the redis-rb library to handle object conversion.
                     Add more here later}

  s.rubyforge_project = "redis-wrapper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [%q{lib}]
  
  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>, ["~> 2.2.1"])
      s.add_development_dependency(%q<git>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["= 2.8.0"])
    else
      s.add_dependency(%q<redis>, ["~> 2.2.1"])
      s.add_dependency(%q<git>, [">= 0"])
      s.add_dependency(%q<rspec>, ["= 2.8.0"])
    end
  else
    s.add_dependency(%q<redis>, ["~> 2.2.1"])
    s.add_dependency(%q<git>, [">= 0"])
    s.add_dependency(%q<rspec>, ["= 2.8.0"])
  end
end
