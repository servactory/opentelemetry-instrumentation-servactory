# OpenTelemetry Servactory Instrumentation

Instrumentation for the [Servactory][servactory-home] service object framework. Automatically traces `call`/`call!` invocations and individual actions with span attributes, failure detection, and error recording.

## How do I get started?

Install the gem using:

```console
gem install opentelemetry-instrumentation-servactory
```

Or, if you use [bundler][bundler-home], include `opentelemetry-instrumentation-servactory` in your `Gemfile`:

```ruby
gem "opentelemetry-instrumentation-servactory"
```

## Requirements

| Requirement | Version |
| --- | --- |
| Servactory | `>= 2.16.0` |
| Ruby | `>= 3.2` |

## Usage

To use the instrumentation, call `use` with the name of the instrumentation:

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use("OpenTelemetry::Instrumentation::Servactory")
end
```

Alternatively, you can also call `use_all` to install all the available instrumentation:

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use_all
end
```

## Configuration Options

| Option | Default | Type | Description |
| --- | --- | --- | --- |
| `trace_actions` | `true` | Boolean | Create child spans for each `make` action |
| `record_input_names` | `true` | Boolean | Record input names as a span attribute |
| `record_output_names` | `true` | Boolean | Record output names as a span attribute |

Example with custom configuration:

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use(
    "OpenTelemetry::Instrumentation::Servactory", {
      trace_actions: true,
      record_input_names: false,
      record_output_names: false
    }
  )
end
```

## Span Structure

Each `call`/`call!` invocation creates a root span. When `trace_actions` is enabled, each `make` action creates a child span.

```
Users::CreateService call              (root span)
  |-- Users::CreateService validate    (child span per action)
  |-- Users::CreateService create_user
  |-- Users::CreateService send_email
```

### Span Attributes

| Attribute | Type | Description |
| --- | --- | --- |
| `code.namespace` | String | Service class name |
| `code.function` | String | Method name (`call`, `call!`, or action name) |
| `servactory.result` | String | `success`, `failure`, or `error` |
| `servactory.input_names` | Array | Input attribute names (when `record_input_names` is enabled) |
| `servactory.output_names` | Array | Output attribute names (when `record_output_names` is enabled) |

### Failure Events

When a service fails via `fail!`, a `servactory.failure` event is added to the span with:

| Attribute | Type | Description |
| --- | --- | --- |
| `servactory.failure.type` | String | Failure type (if provided) |
| `servactory.failure.message` | String | Failure message |

## License

The `opentelemetry-instrumentation-servactory` gem is distributed under the MIT license. See [LICENSE][license-github] for more information.

[servactory-home]: https://servactory.com
[bundler-home]: https://bundler.io
[license-github]: https://github.com/servactory/opentelemetry-instrumentation-servactory/blob/main/LICENSE
