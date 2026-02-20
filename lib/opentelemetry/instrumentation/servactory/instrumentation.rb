# frozen_string_literal: true

module OpenTelemetry
  module Instrumentation
    module Servactory
      class Instrumentation < OpenTelemetry::Instrumentation::Base
        instrumentation_version VERSION::STRING

        MINIMUM_VERSION = Gem::Version.new("2.16.0")

        install do |_config|
          require_dependencies
          patch_callable
          patch_runner if config[:trace_actions]
        end

        present do
          defined?(::Servactory)
        end

        compatible do
          gem_version = Gem::Version.new(::Servactory::VERSION::STRING)
          gem_version >= MINIMUM_VERSION
        end

        option :trace_actions, default: true, validate: :boolean
        option :record_input_names, default: true, validate: :boolean
        option :record_output_names, default: true, validate: :boolean

        private

        def require_dependencies
          require_relative "patches/callable"
          require_relative "patches/runner"
        end

        def patch_callable
          ::Servactory::Context::Callable.prepend(Patches::Callable)
        end

        def patch_runner
          ::Servactory::Actions::Tools::Runner.prepend(Patches::Runner)
        end
      end
    end
  end
end
