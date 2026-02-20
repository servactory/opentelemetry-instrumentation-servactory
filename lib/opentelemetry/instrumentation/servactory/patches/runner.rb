# frozen_string_literal: true

module OpenTelemetry
  module Instrumentation
    module Servactory
      module Patches
        module Runner
          private

          def call_action(action)
            span = start_action_span(action)
            OpenTelemetry::Trace.with_span(span) do
              super
            rescue StandardError => e
              span.record_exception(e)
              span.status = OpenTelemetry::Trace::Status.error("Unhandled exception of type: #{e.class}")
              raise
            ensure
              span.finish
            end
          end

          def start_action_span(action)
            service_name = @context.class.name || "AnonymousService"

            tracer.start_span(
              "#{service_name} #{action.name}",
              attributes: { "code.namespace" => service_name, "code.function" => action.name.to_s },
              kind: :internal
            )
          end

          def tracer
            OpenTelemetry::Instrumentation::Servactory::Instrumentation.instance.tracer
          end
        end
      end
    end
  end
end
