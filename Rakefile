desc 'Release redis_wrapper, and redis_wrapper_rails to Gemcutter'
task :release do
  FileUtils.cp('README.md', 'redis_wrapper/')

  require File.expand_path('./redis_wrapper/lib/redis_wrapper/version', __FILE__)

  version_tag = "v#{RedisWrapper::VERSION}"
  system "git tag -am 'Release version #{RedisWrapper::VERSION}' '#{version_tag}'"
  system "git push origin #{version_tag}:#{version_tag}"

  FileUtils.cd 'sunspot' do
    system "gem build redis_wrapper.gemspec"
    system "gem push redis_wrapper-#{RedisWrapper::VERSION}.gem"
    FileUtils.rm "redis_wrapper-#{RedisWrapper::VERSION}.gem"
  end

  FileUtils.cd 'redis_wrapper_rails' do
    system "gem build redis_wrapper_rails.gemspec"
    system "gem push redis_wrapper_rails-#RedisWrapper::VERSION}.gem"
    FileUtils.rm("redis_wrapper_rails-#{RedisWrapper::VERSION}.gem")
  end
end