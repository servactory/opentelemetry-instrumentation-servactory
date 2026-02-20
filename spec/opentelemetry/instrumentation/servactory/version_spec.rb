# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::VERSION do
  it { expect(described_class::STRING).not_to be_nil }
end
