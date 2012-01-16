module RedisWrapper
  module Rails
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        Thread.current["sorl_runtime"] = value
      end

      def self.runtime
        Thread.current["sorl_runtime"] ||= 0
      end

      def self.reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end

      def request(event)
        self.class.runtime += event.duration
        return unless logger.debug?

        name = '%s (%.1fms)' % ["Redis Request", event.duration]

        debug "  #{color(name, RED, true)}  [ method: #{event.payload[:method]}  #{"| key: " + event.payload[:key] if event.payload[:key].present?}]"
      end
    end
  end
end

RedisWrapper::Rails::LogSubscriber.attach_to :redis
