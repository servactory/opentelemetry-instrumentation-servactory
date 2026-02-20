# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::Instrumentation do
  subject(:instrumentation) { described_class.instance }

  it "has a name" do
    expect(instrumentation.name).to eq("OpenTelemetry::Instrumentation::Servactory")
  end

  it "has a version" do
    expect(instrumentation.version).to eq(OpenTelemetry::Instrumentation::Servactory::VERSION::STRING)
  end

  describe "#present?" do
    it { expect(instrumentation).to be_present }
  end

  describe "#compatible?" do
    it { expect(instrumentation.compatible?).to be true }
  end

  describe "#install" do
    before { instrumentation.install }

    it "sets default config options", :aggregate_failures do
      expect(instrumentation.config[:trace_actions]).to be true
      expect(instrumentation.config[:record_input_names]).to be true
      expect(instrumentation.config[:record_output_names]).to be true
    end
  end
end
