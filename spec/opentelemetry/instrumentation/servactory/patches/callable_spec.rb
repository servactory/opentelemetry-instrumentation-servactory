# frozen_string_literal: true

RSpec.describe OpenTelemetry::Instrumentation::Servactory::Patches::Callable do
  let(:exporter) { EXPORTER }
  let(:spans) { exporter.finished_spans }

  before do
    exporter.reset
  end

  describe "#call" do
    context "when service succeeds" do
      before { SuccessfulService.call(name: "World") }

      it "creates a span with correct name" do
        root_span = spans.find { |s| s.name == "SuccessfulService call" }
        expect(root_span).not_to be_nil
      end

      it "sets success result attribute" do
        root_span = spans.find { |s| s.name == "SuccessfulService call" }
        expect(root_span.attributes["servactory.result"]).to eq("success")
      end

      it "sets OK status" do
        root_span = spans.find { |s| s.name == "SuccessfulService call" }
        expect(root_span.status.code).to eq(OpenTelemetry::Trace::Status::OK)
      end

      it "sets code.namespace attribute" do
        root_span = spans.find { |s| s.name == "SuccessfulService call" }
        expect(root_span.attributes["code.namespace"]).to eq("SuccessfulService")
      end

      it "sets code.function attribute" do
        root_span = spans.find { |s| s.name == "SuccessfulService call" }
        expect(root_span.attributes["code.function"]).to eq("call")
      end

      it "records input names" do
        root_span = spans.find { |s| s.name == "SuccessfulService call" }
        expect(root_span.attributes["servactory.input_names"]).to eq(["name"])
      end

      it "records output names" do
        root_span = spans.find { |s| s.name == "SuccessfulService call" }
        expect(root_span.attributes["servactory.output_names"]).to eq(["greeting"])
      end
    end

    it "returns the result" do
      result = SuccessfulService.call(name: "World")

      expect(result.greeting).to eq("Hello, World!")
    end

    context "when service fails" do
      before { FailingService.call(should_fail: true) }

      it "sets failure result attribute" do
        root_span = spans.find { |s| s.name == "FailingService call" }
        expect(root_span.attributes["servactory.result"]).to eq("failure")
      end

      it "sets ERROR status" do
        root_span = spans.find { |s| s.name == "FailingService call" }
        expect(root_span.status.code).to eq(OpenTelemetry::Trace::Status::ERROR)
      end

      it "adds a failure event" do
        root_span = spans.find { |s| s.name == "FailingService call" }
        failure_event = root_span.events&.find { |e| e.name == "servactory.failure" }
        expect(failure_event).not_to be_nil
      end
    end

    it "returns the failure result" do
      result = FailingService.call(should_fail: true)

      expect(result.failure?).to be true
    end

    context "when service does not fail" do
      it "sets success result" do
        FailingService.call(should_fail: false)

        root_span = spans.find { |s| s.name == "FailingService call" }
        expect(root_span.attributes["servactory.result"]).to eq("success")
      end
    end
  end

  describe "#call!" do
    context "when service succeeds" do
      before { SuccessfulService.call!(name: "World") }

      it "creates a span with correct name" do
        root_span = spans.find { |s| s.name == "SuccessfulService call!" }
        expect(root_span).not_to be_nil
      end

      it "sets success result attribute" do
        root_span = spans.find { |s| s.name == "SuccessfulService call!" }
        expect(root_span.attributes["servactory.result"]).to eq("success")
      end

      it "sets OK status" do
        root_span = spans.find { |s| s.name == "SuccessfulService call!" }
        expect(root_span.status.code).to eq(OpenTelemetry::Trace::Status::OK)
      end
    end

    it "returns the result" do
      result = SuccessfulService.call!(name: "World")

      expect(result.greeting).to eq("Hello, World!")
    end

    context "when service fails with exception" do
      before do
        FailingService.call!(should_fail: true)
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end

      it "records the exception" do
        root_span = spans.find { |s| s.name == "FailingService call!" }
        exception_event = root_span.events&.find { |e| e.name == "exception" }
        expect(exception_event).not_to be_nil
      end

      it "sets failure result for Servactory failures" do
        root_span = spans.find { |s| s.name == "FailingService call!" }
        expect(root_span.attributes["servactory.result"]).to eq("failure")
      end

      it "sets ERROR status" do
        root_span = spans.find { |s| s.name == "FailingService call!" }
        expect(root_span.status.code).to eq(OpenTelemetry::Trace::Status::ERROR)
      end
    end

    it "re-raises the exception" do
      expect { FailingService.call!(should_fail: true) }.to raise_error(StandardError, /Something went wrong/)
    end

    context "when service raises unexpected exception" do
      before do
        ExceptionService.call!
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end

      it "records the exception" do
        root_span = spans.find { |s| s.name == "ExceptionService call!" }
        exception_event = root_span.events&.find { |e| e.name == "exception" }
        expect(exception_event).not_to be_nil
      end

      it "sets error result" do
        root_span = spans.find { |s| s.name == "ExceptionService call!" }
        expect(root_span.attributes["servactory.result"]).to eq("error")
      end
    end
  end
end
