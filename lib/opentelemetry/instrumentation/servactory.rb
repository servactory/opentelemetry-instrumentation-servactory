# frozen_string_literal: true

require "opentelemetry"
require "opentelemetry-instrumentation-base"

module OpenTelemetry
  module Instrumentation
    module Servactory
    end
  end
end

require_relative "servactory/instrumentation"
require_relative "servactory/version"
