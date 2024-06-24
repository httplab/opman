module Op::Lite::ResultHelpers
  def success(...)
    Op::Lite::Success.new(args_to_value(...))
  end

  def failure(*args, **)
    error = args.shift

    Op::Lite::Failure.new(error, args_to_value(*args, **))
  end

  def args_to_value(*args, **kwargs)
    value = args
    value << kwargs if kwargs.any?
    value = value.first if value.size <= 1
    value
  end
end

class Op::Lite::Result
  extend Op::Lite::ResultHelpers

  attr_accessor :error, :value

  def initialize(_success, _value = nil) = nil

  def success? = @error.nil?

  def failure? = !success?

  alias fail? failure?
  alias failed? failure?

  def kwargs
    return value if value.is_a?(Hash)
    return value.last if value.is_a?(Array) && value.last.is_a?(Hash)

    {}
  end

  def [](key)
    return value[key] if value.is_a?(Array) && key.is_a?(Integer)
    return value[key] if value.is_a?(Hash)
    return kwargs[key] if kwargs.present?

    nil
  end

  def respond_to_missing?(m, include_private = false)
    kwargs.key?(m.to_sym) || super
  end

  def method_missing(m, *args, &)
    kwargs[m.to_sym] || super
  end
end

class Op::Lite::Success < Op::Lite::Result
  def initialize(value = nil)
    @value = value
  end
end

class Op::Lite::Failure < Op::Lite::Result
  def initialize(error, value = nil)
    @error = error
    @value = value
  end
end
