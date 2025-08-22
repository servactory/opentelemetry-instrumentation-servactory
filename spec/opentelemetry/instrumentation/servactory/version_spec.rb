# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::VERSION do
  it { expect(OpenTelemetry::Instrumentation::Servactory::VERSION::STRING).not_to be_nil }
end
