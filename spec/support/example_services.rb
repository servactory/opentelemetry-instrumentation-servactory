# frozen_string_literal: true

class SuccessfulService < Servactory::Base
  input :name, type: String

  output :greeting, type: String

  make :build_greeting

  private

  def build_greeting
    outputs.greeting = "Hello, #{inputs.name}!"
  end
end

class FailingService < Servactory::Base
  input :should_fail, type: [TrueClass, FalseClass]

  make :maybe_fail

  private

  def maybe_fail
    fail!(message: "Something went wrong") if inputs.should_fail
  end
end

class MultiActionService < Servactory::Base
  input :value, type: Integer

  internal :temp, type: Integer

  output :result, type: Integer

  make :step_one
  make :step_two

  private

  def step_one
    internals.temp = inputs.value * 2
  end

  def step_two
    outputs.result = internals.temp + 1
  end
end

class ExceptionService < Servactory::Base
  make :blow_up

  private

  def blow_up
    raise StandardError, "unexpected error"
  end
end
