# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::Patches::Callable do
  let(:spans) { EXPORTER.finished_spans }

  describe "#call" do
    context "when service succeeds" do
      subject(:result) { SuccessfulService.call(name: "World") }

      let(:span) { spans.find { |s| s.name == "SuccessfulService call" } }

      before { result }

      it "creates a span" do
        expect(span)
          .not_to be_nil
      end

      it "sets span attributes", :aggregate_failures do
        expect(span.attributes["code.namespace"])
          .to eq("SuccessfulService")
        expect(span.attributes["code.function"])
          .to eq("call")
        expect(span.attributes["servactory.system"])
          .to eq("servactory")
        expect(span.attributes["servactory.version"])
          .to eq(Servactory::VERSION::STRING)
        expect(span.attributes["servactory.result"])
          .to eq("success")
        expect(span.attributes["servactory.input_names"])
          .to eq(["name"])
        expect(span.attributes["servactory.output_names"])
          .to eq(["greeting"])
      end

      it "sets OK status" do
        expect(span.status.code)
          .to eq(OpenTelemetry::Trace::Status::OK)
      end

      it "does not alter the return value" do
        expect(result.greeting)
          .to eq("Hello, World!")
      end
    end

    context "when service fails" do
      subject(:result) { FailingService.call(should_fail: true) }

      let(:span) { spans.find { |s| s.name == "FailingService call" } }
      let(:failure_event) { span.events&.find { |e| e.name == "servactory.failure" } }

      before { result }

      it "sets span attributes", :aggregate_failures do
        expect(span.attributes["servactory.result"])
          .to eq("failure")
        expect(span.status.code)
          .to eq(OpenTelemetry::Trace::Status::ERROR)
      end

      it "adds a failure event" do
        expect(failure_event)
          .not_to be_nil
      end

      it "returns a failure result" do
        expect(result)
          .to be_failure
      end
    end

    context "when service does not fail" do
      let(:span) { spans.find { |s| s.name == "FailingService call" } }

      before { FailingService.call(should_fail: false) }

      it "sets success result" do
        expect(span.attributes["servactory.result"])
          .to eq("success")
      end
    end

    context "when service raises unexpected exception" do
      let(:span) { spans.find { |s| s.name == "ExceptionService call" } }
      let(:exception_event) { span.events&.find { |e| e.name == "exception" } }

      before do
        ExceptionService.call
      rescue StandardError
        nil
      end

      it "records the exception on span" do
        expect(exception_event)
          .not_to be_nil
      end

      it "sets error result" do
        expect(span.attributes["servactory.result"])
          .to eq("error")
      end

      it "re-raises the exception" do
        expect { ExceptionService.call }
          .to raise_error(StandardError, /unexpected error/)
      end
    end
  end

  describe "#call!" do
    context "when service succeeds" do
      subject(:result) { SuccessfulService.call!(name: "World") }

      let(:span) { spans.find { |s| s.name == "SuccessfulService call!" } }

      before { result }

      it "creates a span" do
        expect(span)
          .not_to be_nil
      end

      it "sets span attributes", :aggregate_failures do
        expect(span.attributes["servactory.result"])
          .to eq("success")
        expect(span.status.code)
          .to eq(OpenTelemetry::Trace::Status::OK)
      end

      it "does not alter the return value" do
        expect(result.greeting)
          .to eq("Hello, World!")
      end
    end

    context "when service fails with Servactory failure" do
      let(:span) { spans.find { |s| s.name == "FailingService call!" } }
      let(:exception_event) { span.events&.find { |e| e.name == "exception" } }

      before do
        FailingService.call!(should_fail: true)
      rescue StandardError
        nil
      end

      it "records the exception on span" do
        expect(exception_event)
          .not_to be_nil
      end

      it "sets span attributes", :aggregate_failures do
        expect(span.attributes["servactory.result"])
          .to eq("failure")
        expect(span.status.code)
          .to eq(OpenTelemetry::Trace::Status::ERROR)
      end

      it "re-raises the exception" do
        expect { FailingService.call!(should_fail: true) }
          .to raise_error(StandardError, /Something went wrong/)
      end
    end

    context "when service raises unexpected exception" do
      let(:span) { spans.find { |s| s.name == "ExceptionService call!" } }
      let(:exception_event) { span.events&.find { |e| e.name == "exception" } }

      before do
        ExceptionService.call!
      rescue StandardError
        nil
      end

      it "records the exception on span" do
        expect(exception_event)
          .not_to be_nil
      end

      it "sets error result" do
        expect(span.attributes["servactory.result"])
          .to eq("error")
      end
    end
  end
end
