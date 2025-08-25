# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default, :development)

# WTF: fixes "uninitialized constant Servactory::Configuration::CollectionMode::ClassNamesCollection::Forwardable"
require "forwardable"

require "servactory"
require "opentelemetry/instrumentation/servactory"

require_relative "otel_helper"
require_relative "rspec_helper"
