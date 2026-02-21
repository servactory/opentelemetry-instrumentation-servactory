# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::Patches::Runner do
  let(:spans) { EXPORTER.finished_spans }

  describe "#call_action" do
    context "when service has multiple actions" do
      subject(:result) { MultiActionService.call(value: 5) }

      let(:root_span) { spans.find { |s| s.name == "MultiActionService call" } }
      let(:step_one_span) { spans.find { |s| s.name == "MultiActionService step_one" } }
      let(:step_two_span) { spans.find { |s| s.name == "MultiActionService step_two" } }

      before { result }

      it "creates child spans for each action", :aggregate_failures do
        expect(step_one_span)
          .not_to be_nil
        expect(step_two_span)
          .not_to be_nil
      end

      it "sets span attributes", :aggregate_failures do
        expect(step_one_span.attributes["code.namespace"])
          .to eq("MultiActionService")
        expect(step_one_span.attributes["code.function"])
          .to eq("step_one")
        expect(step_one_span.attributes["servactory.version"])
          .to eq(Servactory::VERSION::STRING)
      end

      it "creates action spans as children of the root span" do
        expect(step_one_span.parent_span_id)
          .to eq(root_span.span_id)
      end

      it "does not alter the return value" do
        expect(result.result)
          .to eq(11)
      end
    end

    context "when action raises an exception" do
      let(:span) { spans.find { |s| s.name == "ExceptionService blow_up" } }
      let(:exception_event) { span.events&.find { |e| e.name == "exception" } }

      before do
        ExceptionService.call
      rescue StandardError
        nil
      end

      it "records exception on action span" do
        expect(exception_event)
          .not_to be_nil
      end

      it "sets ERROR status on action span" do
        expect(span.status.code)
          .to eq(OpenTelemetry::Trace::Status::ERROR)
      end
    end
  end
end
