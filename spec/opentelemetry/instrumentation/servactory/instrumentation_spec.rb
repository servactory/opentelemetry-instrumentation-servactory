# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::Instrumentation do
  let(:instrumentation) { described_class.instance }

  it "has a name" do
    expect(instrumentation.name).to eq("OpenTelemetry::Instrumentation::Servactory")
  end

  it "has a version" do
    expect(instrumentation.version).to eq(OpenTelemetry::Instrumentation::Servactory::VERSION::STRING)
  end

  describe "present?" do
    it "returns true when Servactory is defined" do
      expect(instrumentation).to be_present
    end
  end

  describe "compatible?" do
    it "returns true for supported Servactory versions" do
      expect(instrumentation.compatible?).to be true
    end
  end

  describe "install" do
    it "installs with default config" do
      expect(instrumentation.install).not_to be_nil
    end

    it "has trace_actions enabled by default" do
      instrumentation.install
      expect(instrumentation.config[:trace_actions]).to be true
    end

    it "has record_input_names enabled by default" do
      instrumentation.install
      expect(instrumentation.config[:record_input_names]).to be true
    end

    it "has record_output_names enabled by default" do
      instrumentation.install
      expect(instrumentation.config[:record_output_names]).to be true
    end
  end
end
