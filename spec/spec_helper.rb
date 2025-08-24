# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:test)

require "forwardable"
require "servactory"
require "opentelemetry/instrumentation/servactory"

# require "servactory/test_kit/rspec/helpers"
# require "servactory/test_kit/rspec/matchers"

require_relative "otel_helper"
require_relative "rspec_helper"
