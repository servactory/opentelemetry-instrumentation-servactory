# frozen_string_literal: true

require "forwardable"
require "servactory"
require "opentelemetry/instrumentation/servactory"
require "opentelemetry-sdk"

Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

EXPORTER = OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect

    # Configures the maximum character length that RSpec will print while
    # formatting an object. You can set length to nil to prevent RSpec from
    # doing truncation.
    c.max_formatted_output_length = nil
  end

  config.before do
    EXPORTER.reset
  end
end

OpenTelemetry::SDK.configure do |c|
  c.error_handler = ->(exception:, message:) { raise(exception || message) }
  c.add_span_processor(OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(EXPORTER))
  c.use("OpenTelemetry::Instrumentation::Servactory")
end
