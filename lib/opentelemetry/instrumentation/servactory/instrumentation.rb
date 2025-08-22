# frozen_string_literal: true

module OpenTelemetry
  module Instrumentation
    module Servactory
      class Instrumentation < OpenTelemetry::Instrumentation::Base
        install do |_config|
          require_dependencies
        end

        present do
          # TODO: Replace true with a definition check of the gem being instrumented
          # Example: `defined?(::Rack)`
          true
        end

        private

        def require_dependencies
          # TODO: Include instrumentation dependencies
        end
      end
    end
  end
end
