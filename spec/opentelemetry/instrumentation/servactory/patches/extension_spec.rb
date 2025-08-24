# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory do
  let(:instrumentation) { OpenTelemetry::Instrumentation::Servactory::Instrumentation.instance }
  let(:exporter) { EXPORTER }

  let(:spans) { exporter.finished_spans }
  let(:root_span) { spans.find { |s| s.parent_span_id == OpenTelemetry::Trace::INVALID_SPAN_ID } }

  let(:dummy_service) do
    Class.new(::Servactory::Base) do
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
        let(:target_span) { nil }

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
