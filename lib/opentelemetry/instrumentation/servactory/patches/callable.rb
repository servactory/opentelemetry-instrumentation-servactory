# frozen_string_literal: true

module OpenTelemetry
  module Instrumentation
    module Servactory
      module Patches
        module Callable
          def call(arguments = {})
            service_name = name || "AnonymousService"
            attributes = build_span_attributes(service_name, "call")

            tracer.in_span("#{service_name} call", attributes:, kind: :internal) do |span|
              result = super
              record_result(span, result)
              result
            end
          end

          def call!(arguments = {}) # rubocop:disable Metrics/MethodLength
            service_name = name || "AnonymousService"
            attributes = build_span_attributes(service_name, "call!")

            span = tracer.start_span("#{service_name} call!", attributes:, kind: :internal)
            OpenTelemetry::Trace.with_span(span) do
              result = super
              mark_span_success(span)
              result
            rescue StandardError => e
              record_exception_on_span(span, e)
              raise
            ensure
              span.finish
            end
          end

          private

          def build_span_attributes(service_name, method_name)
            attributes = { "code.namespace" => service_name, "code.function" => method_name }
            append_attribute_names(attributes)
            attributes
          end

          def append_attribute_names(attributes)
            config = OpenTelemetry::Instrumentation::Servactory::Instrumentation.instance.config

            if config[:record_input_names]
              names = input_names
              attributes["servactory.input_names"] = names unless names.empty?
            end

            return unless config[:record_output_names]

            names = output_names
            attributes["servactory.output_names"] = names unless names.empty?
          end

          def input_names
            send(:collection_of_inputs).names.map(&:to_s)
          rescue StandardError
            []
          end

          def output_names
            send(:collection_of_outputs).names.map(&:to_s)
          rescue StandardError
            []
          end

          def record_result(span, result)
            if result.respond_to?(:failure?) && result.failure?
              record_failure_on_span(span, result)
              span.set_attribute("servactory.result", "failure")
            else
              mark_span_success(span)
            end
          end

          def mark_span_success(span)
            span.set_attribute("servactory.result", "success")
            span.status = OpenTelemetry::Trace::Status.ok
          end

          def record_failure_on_span(span, result)
            error = result.respond_to?(:error) ? result.error : nil
            message = error_message_for(error)

            span.add_event("servactory.failure", attributes: failure_attributes(error))
            span.status = OpenTelemetry::Trace::Status.error(message)
          end

          def record_exception_on_span(span, exception)
            span.record_exception(exception)

            if exception.respond_to?(:type)
              span.set_attribute("servactory.result", "failure")
              span.status = OpenTelemetry::Trace::Status.error(error_message_for(exception))
            else
              span.set_attribute("servactory.result", "error")
              span.status = OpenTelemetry::Trace::Status.error("Unhandled exception of type: #{exception.class}")
            end
          end

          def error_message_for(error)
            return "Service failure" unless error

            if error.respond_to?(:message)
              error.message.to_s
            else
              error.to_s
            end
          end

          def failure_attributes(error)
            attrs = {}
            attrs["servactory.failure.type"] = error.type.to_s if error.respond_to?(:type) && error.type
            attrs["servactory.failure.message"] = error.message.to_s if error.respond_to?(:message) && error.message
            attrs
          end

          def tracer
            OpenTelemetry::Instrumentation::Servactory::Instrumentation.instance.tracer
          end
        end
      end
    end
  end
end
