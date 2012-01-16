module RedisWrapper
  module Rails
    module Railties
      module ControllerRuntime
        extend ActiveSupport::Concern

        protected

        attr_internal :redis_runtime

        def cleanup_view_runtime
          #TODO: Call only if redis is connected
          redis_rt_before_render = Rails::LogSubscriber.reset_runtime
          runtime = super
          redis_rt_after_render = Rails::LogSubscriber.reset_runtime
          self.redis_runtime = redis_rt_before_render + redis_rt_after_render
          runtime - redis_rt_after_render
        end

        def append_info_to_payload(payload)
          super
          payload[:redis_runtime] = redis_runtime
        end

        module ClassMethods
          def log_process_action(payload)
            messages, redis_runtime = super, payload[:redis_runtime]
            messages << ("Redis: %.1fms" % redis_runtime.to_f) if redis_runtime
            messages
          end
        end
      end
    end
  end
end