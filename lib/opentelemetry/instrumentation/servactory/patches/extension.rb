# frozen_string_literal: true

module OpenTelemetry
  module Instrumentation
    module Servactory
      module Patches
        module Extension
          def self.included(base)
            class << base
              prepend ClassMethods
            end
          end

          module ClassMethods
            def call(...)
              tracer
                .in_span(
                  name,
                  attributes: {
                    "service" => name,
                    "method" => __method__.to_s,
                    "type" => ::Servactory.name.underscore,
                    "version" => ::Servactory::VERSION::STRING
                  }
                ) do
                super
              end
            end

            def call!(...)
              tracer.in_span(
                name,
                attributes: {
                  "service" => name,
                  "method" => __method__.to_s,
                  "type" => ::Servactory.name.underscore,
                  "version" => ::Servactory::VERSION::STRING
                }
              ) do
                super
              end
            end

            def tracer
              Servactory::Instrumentation.instance.tracer
            end
          end
        end
      end
    end
  end
end
