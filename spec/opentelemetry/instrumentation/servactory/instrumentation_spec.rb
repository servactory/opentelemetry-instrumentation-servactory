# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory do
  let(:instrumentation) { OpenTelemetry::Instrumentation::Servactory::Instrumentation.instance }

  describe "fields" do
    it 'has #name' do
      expect(instrumentation.name).to(eq('OpenTelemetry::Instrumentation::Servactory'))
    end

    it 'has #version' do
      expect(instrumentation.version::STRING).to(eq('0.1.0'))
    end
  end

  describe '#install' do
    let(:config) { { base_class: } }

    before do
      skip "#{Servactory::VERSION} is not supported" unless instrumentation.compatible?
      allow(OpenTelemetry.logger).to(receive(:error))
    end

    after do
      # Force re-install of instrumentation
      instrumentation.instance_variable_set(:@installed, false)
      instrumentation.instance_variable_set(:@config, {})
    end

    context "with valid config" do
      let(:base_class) { Class.new }

      it 'accepts argument' do
        expect(instrumentation.install(config)).to(be_truthy)
      end

      it "does not warn about config" do
        instrumentation.install(config)

        expect(OpenTelemetry.logger).not_to(
          have_received(:error)
        )
      end
    end

    context "with invalid config" do
      let(:base_class) { nil }

      it 'warns about nil base class' do
        instrumentation.install(config)

        expect(OpenTelemetry.logger).to(
          have_received(:error).with(
            "Instrumentation Servactory configuration option :base_class value=nil " \
              "failed validation, installation aborted."
          )
        )
      end
    end
  end
end
