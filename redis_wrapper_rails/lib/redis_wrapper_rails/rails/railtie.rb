module RedisWrapper
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'redis_wrapper.init' do
        require 'redis_wrapper_rails/rails/log_subscriber'
        RedisWrapper.module_eval{ include Rails::RedisInstrumentation }
      end

      # Expose redis runtime to controller for logging.
      initializer "redis_wrapper_rails.log_runtime" do |app|
        require "redis_wrapper_rails/rails/railties/controller_runtime"
        ActiveSupport.on_load(:action_controller) do
          include Rails::Railties::ControllerRuntime
        end
      end

      rake_tasks do
        load 'redis_wrapper_rails/rails/tasks.rb'
      end
    end
  end
end
