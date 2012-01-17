# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "redis_wrapper"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["wakemaster39"]
  s.date = "2012-01-17"
  s.description = "A high level wrapper around the redis-rb gem and API. Designed to be a drop in replacement for Redis class while handling object marshaling and compression, setting key expiries, and namespacing your keys"
  s.email = "wakemaster39@gmail.com"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "CHANGELOG",
    "Gemfile",
    "MIT-LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/redis_wrapper.rb",
    "lib/redis_wrapper/entry.rb",
    "lib/redis_wrapper/redis_wrapper.rb",
    "redis_wrapper.gemspec",
    "tests/rspec/entry_spec.rb",
    "tests/rspec/redis_wrapper_spec.rb"
  ]
  s.homepage = "http://github.com/wakemaster39/redis-wrapper"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "High level wrapper around redis API"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

