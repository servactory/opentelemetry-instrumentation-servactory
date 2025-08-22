# OpenTelemetry Servactory Instrumentation

Todo: Add a description.

## How do I get started?

Install the gem using:

```console
gem install opentelemetry-instrumentation-servactory
```

Or, if you use [bundler][bundler-home], include `opentelemetry-instrumentation-servactory` in your `Gemfile`.

## Usage

To use the instrumentation, call `use` with the name of the instrumentation:

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::Servactory'
end
```

Alternatively, you can also call `use_all` to install all the available instrumentation.

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use_all
end
```

## Examples

Example usage can be seen in the [`./example/trace_demonstration.rb` file](https://github.com/servactory/opentelemetry-instrumentation-servactory/blob/main/example/trace_demonstration.rb)

## License

The `opentelemetry-instrumentation-servactory` gem is distributed under the MIT license. See [LICENSE][license-github] for more information.

[bundler-home]: https://bundler.io
[license-github]: https://github.com/servactory/opentelemetry-instrumentation-servactory/blob/main/LICENSE
