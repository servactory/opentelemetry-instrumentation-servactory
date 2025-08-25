# frozen_string_literal: true

module OpenTelemetry
  module Instrumentation
    module Servactory
      class Instrumentation < OpenTelemetry::Instrumentation::Base
        MINIMUM_VERSION = Gem::Version.new("2.16.0")

        install do |_config|
          require_dependencies
          install_patches
        end

        # TODO: constantize base_class from config[:base_class]
        option :base_class, default: nil, validate: ->(value) { value.present? && value.is_a?(Class) }

        present do
          defined?(::Servactory)
        end

        compatible do
          Gem::Version.new(::Servactory::VERSION::STRING) >= MINIMUM_VERSION
        end

        private

        def require_dependencies
          require_relative "patches/extension"
        end

        def install_patches
          base_class = prepare_base_class
          return if base_class.blank?

          base_class.include(
            ::Servactory::DSL.with_extensions(Patches::Extension)
          )
        end

        def prepare_base_class
          # TODO: maybe constantize base_class from config[:base_class]?
          base_class = config[:base_class]

          if base_class.blank?
            OpenTelemetry.logger.error(
              "Instrumentation Servactory configuration option :base_class value=#{base_class.inspect} " \
              "failed validation, installation aborted."
            )

            return
          end

          base_class
        end
      end
    end
  end
end
