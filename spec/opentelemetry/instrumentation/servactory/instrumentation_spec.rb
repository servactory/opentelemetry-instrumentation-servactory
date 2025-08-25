# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::Instrumentation do
  let(:instrumentation) { described_class.instance }

  describe "fields" do
    it "has #name" do
      expect(instrumentation.name).to(eq("OpenTelemetry::Instrumentation::Servactory"))
    end

    it "has #version" do
      expect(instrumentation.version::STRING).to(eq("0.1.0"))
    end
  end

  describe "#install" do
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

      it "accepts argument" do
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

      it "warns about nil base class" do
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

  describe "span creation" do
    let(:exporter) { EXPORTER }
    let(:spans) { exporter.finished_spans }
    let(:root_span) { spans.find { |s| s.parent_span_id == OpenTelemetry::Trace::INVALID_SPAN_ID } }

    let(:dummy_service) do
      Class.new(Servactory::Base) do
        def self.name = "DummyService"

        make :step

        def step; end
      end
    end

    before do
      dummy_service
      exporter.reset
      instrumentation.install(config)
    end

    after do
      instrumentation.instance_variable_set(:@installed, false)
      instrumentation.instance_variable_set(:@config, {})
    end

    context "with invalid config" do
      let(:config) { { base_class: nil } }

      shared_examples "expected span creation skip" do |call_strategy:|
        let(:method_name) { call_strategy }
        let(:service_call) { dummy_service.public_send(method_name, {}) }

        it "does not create spans" do
          expect { service_call }.not_to(
            change { exporter.finished_spans.size }
          )
        end
      end

      it_behaves_like "expected span creation skip", call_strategy: "call"
      it_behaves_like "expected span creation skip", call_strategy: "call!"
    end

    context "with valid config" do
      let(:config) { { base_class: dummy_service } }

      shared_examples "successful span creation" do |call_strategy:|
        let(:method_name) { call_strategy }
        let(:service_call) { dummy_service.public_send(method_name, {}) }

        it "creates correct count of spans" do
          expect { service_call }.to(
            change { exporter.finished_spans.size }.by(1)
          )
        end

        shared_examples "correct span attributes" do
          before { service_call }

          it "creates correct spans" do
            expect(target_span).to(
              have_attributes(
                name: "DummyService",
                kind: :internal,
                attributes: {
                  "service" => "DummyService",
                  "method" => method_name,
                  "type" => "servactory",
                  "version" => Servactory::VERSION::STRING
                }
              )
            )
          end
        end

        describe "root span" do
          it_behaves_like "correct span attributes" do
            let(:target_span) { root_span }
          end
        end
      end

      it_behaves_like "successful span creation", call_strategy: "call"
      it_behaves_like "successful span creation", call_strategy: "call!"
    end
  end
end
