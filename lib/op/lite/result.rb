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

  # initialize params _success and _value is not used now and kept for compatibility with
  # "classic" Op::Result class.
  def initialize(_success, _value = nil) = nil

  def success? = @error.nil?

  def failure? = !success?

  alias fail? failure?
  alias failed? failure?

  def [](key)
    return value[key] if value.is_a?(Hash) || (value.is_a?(Array) && key.is_a?(Integer))
    return hash_argument[key] if hash_argument.present?

    nil
  end

  private

  # hash_argument is a helper method which helps to determine if to result was passed a hash or
  # array with hash. In the case operator [] will be working and method_missing will provide access
  # to hash data by "method call style". It can be handy in case of using result in a way like:
  #   result = described_class.success(greeting: 'Hello', name: "Alice")
  #   expect(result.greeting).to eq 'Hello'
  def hash_argument
    return value if value.is_a?(Hash)
    return value.last if value.is_a?(Array) && value.last.is_a?(Hash)

    {}
  end

  def respond_to_missing?(m, include_private = false)
    hash_argument.key?(m.to_sym) || super
  end

  def method_missing(m, *args, &)
    hash_argument[m.to_sym] || super
  end
end

class Op::Lite::Success < Op::Lite::Result
  def initialize(value = nil)
    @value = value
  end
end

# Op::Lite::FailureException is a wrapper for Op::Lite::Failure which allows to raise failure as an
# exception. It is useful when we need to raise an exception with a backtrace and message which was
# passed to the failure result.
class Op::Lite::FailureException < StandardError
  def initialize(failure)
    super(failure.message)

    @cause = failure.cause
    set_backtrace(@cause&.backtrace)
  end

  def cause = @cause || super

  def backtrace_locations = @cause&.backtrace_locations || super
end

# Op::Lite::Failure is a class which represents a failure result of the operation. It pretends to be
# a Ruby exception and provides a message and backtrace methods. It is useful when we want to log
# failure or report it to the Airbrake or other error tracking system.
#
# With Airbrake, it is better to not use Airbrake.notify method because in this case failure will
# be reported as a RuntimeError and backtrace will be ignored. Instead, we need to create a new notice
# and pass it to the Airbrake.notify method, for example:
#
#    result = MyService.call(...)
#    n = Airbrake::Notice.new(result, params: { ... })
#    Airbrake.notify(n)
#
# With this approach, Airbrake will detect backtrace, unwrap original error and show Op::Lite::Failure
# as a exception class instead of RuntimeError.
class Op::Lite::Failure < Op::Lite::Result
  def initialize(error, value = nil)
    @error = error
    @value = value
  end

  # message returns a message which was passed to the result in one of the following ways:
  #   failure(err)
  #   failure(:something_happened, err)
  #   failure(:something_happened, 'Something went wrong')
  #   failure(:something_happened, message: 'Something went wrong')
  def message
    orig_msg = nil
    orig_msg ||= value if value.is_a?(String)
    orig_msg ||= hash_argument[:message] if hash_argument[:message].is_a?(String)
    orig_msg ||= error.to_s.humanize if error.is_a?(Symbol)

    # wrap cause message into the result message if cause exception is present
    [orig_msg, cause&.message].compact.uniq.join(', ')
  end

  def backtrace
    cause&.backtrace || Kernel.caller
  end

  # cause returns an initial ruby exception which was intercepted and wrapped into failure result by
  # passing the exception to the result in one of the following ways:
  #   failure(e)
  #   failure(:exception, e)
  #   failure(:exception, error: e)
  def cause
    if error.is_a?(StandardError)
      error
    elsif value.is_a?(StandardError)
      value
    elsif hash_argument[:error].is_a?(StandardError)
      hash_argument[:error]
    end
  end

  # It allows to raise failure as an exception, usually we don't need that because failure can be
  # reported to Airbrake as is with building a new Airbrake::Notice object.
  def exception
    Op::Lite::FailureException.new(self)
  end

  def to_s
    str = "Op::Failure"
    str += " (#{cause.class.name})" if cause
    str + ": #{message.strip}"
  end
end
