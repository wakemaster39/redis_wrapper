# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_wrapper_rails/rails/version"

Gem::Specification.new do |s|
  s.name        = "redis_wrapper_rails"
  s.version     = RedisWrapper::Rails::VERSION
  s.authors     = ["wakemaster39"]
  s.email       = ["wakemaster39@gmail.com"]
  s.homepage    = "https://github.com/wakemaster39/redis_wrapper"
  s.summary     = %q{Handle rails specifc actions}
  s.description = %q{Adds support for a number of rails specific actions}

  s.rubyforge_project = "redis_wrapper_rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [%q{lib}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis_wrapper>, ["~> 0.0.0.1"])
      s.add_development_dependency(%q<git>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["= 2.8.0"])
    else
      s.add_dependency(%q<redis_wrapper>, ["~> 0.0.0.1"])
      s.add_dependency(%q<git>, [">= 0"])
      s.add_dependency(%q<rspec>, ["= 2.8.0"])
    end
  else
    s.add_dependency(%q<redis_wrapper>, ["~> 0.0.0.1"])
    s.add_dependency(%q<git>, [">= 0"])
    s.add_dependency(%q<rspec>, ["= 2.8.0"])
  end
end
