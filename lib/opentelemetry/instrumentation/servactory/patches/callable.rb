# frozen_string_literal: true

module OpenTelemetry
  module Instrumentation
    module Servactory
      module Patches
        module Callable # rubocop:disable Metrics/ModuleLength
          def call(...) # rubocop:disable Metrics/MethodLength
            service_name = name || "AnonymousService"
            attributes = _otel_build_span_attributes(service_name, "call")

            span = _otel_tracer.start_span("#{service_name} call", attributes:, kind: :internal)
            OpenTelemetry::Trace.with_span(span) do
              result = super
              _otel_record_result(span, result)
              result
            rescue StandardError => e
              _otel_record_exception_on_span(span, e)
              raise
            ensure
              span.finish
            end
          end

          def call!(...) # rubocop:disable Metrics/MethodLength
            service_name = name || "AnonymousService"
            attributes = _otel_build_span_attributes(service_name, "call!")

            span = _otel_tracer.start_span("#{service_name} call!", attributes:, kind: :internal)
            OpenTelemetry::Trace.with_span(span) do
              result = super
              _otel_mark_span_success(span)
              result
            rescue StandardError => e
              _otel_record_exception_on_span(span, e)
              raise
            ensure
              span.finish
            end
          end

          private

          def _otel_build_span_attributes(service_name, method_name)
            attributes = {
              "code.namespace" => service_name,
              "code.function" => method_name,
              "servactory.system" => "servactory",
              "servactory.version" => ::Servactory::VERSION::STRING
            }
            _otel_append_attribute_names(attributes)
            attributes
          end

          def _otel_append_attribute_names(attributes)
            config = OpenTelemetry::Instrumentation::Servactory::Instrumentation.instance.config

            if config[:record_input_names]
              names = _otel_input_names
              attributes["servactory.input_names"] = names unless names.empty?
            end

            return unless config[:record_output_names]

            names = _otel_output_names
            attributes["servactory.output_names"] = names unless names.empty?
          end

          def _otel_input_names
            send(:collection_of_inputs).names.map(&:to_s)
          rescue StandardError => e
            OpenTelemetry.handle_error(exception: e, message: "Failed to collect Servactory input names")
            []
          end

          def _otel_output_names
            send(:collection_of_outputs).names.map(&:to_s)
          rescue StandardError => e
            OpenTelemetry.handle_error(exception: e, message: "Failed to collect Servactory output names")
            []
          end

          def _otel_record_result(span, result)
            if result.respond_to?(:failure?) && result.failure?
              _otel_record_failure_on_span(span, result)
              span.set_attribute("servactory.result", "failure")
            else
              _otel_mark_span_success(span)
            end
          end

          def _otel_mark_span_success(span)
            span.set_attribute("servactory.result", "success")
            span.status = OpenTelemetry::Trace::Status.ok
          end

          def _otel_record_failure_on_span(span, result)
            error = result.respond_to?(:error) ? result.error : nil
            message = _otel_error_message_for(error)

            span.add_event("servactory.failure", attributes: _otel_failure_attributes(error))
            span.status = OpenTelemetry::Trace::Status.error(message)
          end

          def _otel_record_exception_on_span(span, exception)
            span.record_exception(exception)

            if exception.respond_to?(:type)
              span.set_attribute("servactory.result", "failure")
              span.status = OpenTelemetry::Trace::Status.error(_otel_error_message_for(exception))
            else
              span.set_attribute("servactory.result", "error")
              span.status = OpenTelemetry::Trace::Status.error("Unhandled exception of type: #{exception.class}")
            end
          end

          def _otel_error_message_for(error)
            return "Service failure" unless error

            if error.respond_to?(:message)
              error.message.to_s
            else
              error.to_s
            end
          end

          def _otel_failure_attributes(error)
            attrs = {}
            attrs["servactory.failure.type"] = error.type.to_s if error.respond_to?(:type) && error.type
            attrs["servactory.failure.message"] = error.message.to_s if error.respond_to?(:message) && error.message
            attrs
          end

          def _otel_tracer
            OpenTelemetry::Instrumentation::Servactory::Instrumentation.instance.tracer
          end
        end
      end
    end
  end
end
