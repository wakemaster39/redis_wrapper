module RedisWrapper
  module Rails
    module RedisInstrumentation
      extend ActiveSupport::Concern

      included do
        alias_method_chain :method_missing, :as_instrumentation
      end

      module InstanceMethods
        def method_missing_with_as_instrumentation(method, *args, &block)
          key = args.first.kind_of?(String) ? args.first : ""
          ActiveSupport::Notifications.instrument("request.redis",
                                                  {:method => method, :key=>key}) do
            method_missing_without_as_instrumentation(method, *args, &block)
          end
        end
      end
    end
  end
end