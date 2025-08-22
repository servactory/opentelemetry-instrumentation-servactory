# frozen_string_literal: true

require_relative "lib/opentelemetry/instrumentation/servactory/version"

Gem::Specification.new do |spec|
  spec.name          = "opentelemetry-instrumentation-servactory"
  spec.version       = OpenTelemetry::Instrumentation::Servactory::VERSION::STRING
  spec.platform      = Gem::Platform::RUBY

  spec.authors       = ["Anton Sokolov"]
  spec.email         = ["profox.rus@gmail.com"]

  spec.summary       = "Servactory instrumentation for the OpenTelemetry framework"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/servactory/opentelemetry-instrumentation-servactory"

  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://servactory.com"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("lib/**/*.rb") + Dir.glob("*.md") + %w[LICENSE]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 3.2")

  spec.add_dependency "opentelemetry-api", "~> 1.6.0"
  spec.add_dependency "opentelemetry-instrumentation-base", "~> 0.23.0"

  spec.add_development_dependency "appraisal", ">= 2.5"
  spec.add_development_dependency "rspec", ">= 3.13"
  spec.add_development_dependency "servactory-rubocop", ">= 0.9"
end
