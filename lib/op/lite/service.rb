require_relative 'context'
require_relative 'result'
require_relative 'after_hooks'
require_relative 'legacy'

class Op::Lite::Service
  include Op::Lite::ResultHelpers
  include Op::Lite::AfterHooks
  include Op::Lite::Legacy

  attr_reader :context, :parent, :logger

  class << self
    def transactional
      @transactional = true
    end

    def transactional?
      @transactional
    end

    def suppress_errors
      @suppress_errors = true
    end

    def suppress_errors?
      @suppress_errors
    end

    def call(*, **)
      service = new
      service.call(*, **)
    end
  end

  def initialize(context = nil, parent = nil)
    @context = context || Op::Lite::Context.new
    @parent = parent
    @logger = @context.logger || Rails.logger
  end

  def call(...)
    result =
      if perform_in_transaction?
        perform_in_transaction(...)
      else
        perform(...)
      end

    hooks_result = run_after_hooks(result)
    return hooks_result if hooks_result.is_a?(Op::Lite::Failure)

    ensure_result(result)
  rescue StandardError => e
    raise unless suppress_errors?

    failure(:exception, error: e, message: e.message)
  end

  private

  def op(clazz, **)
    clazz.new(context, self)
  end

  def perform_in_transaction? = self.class.transactional? && (parent.nil? || !parent.class.transactional?)

  def perform_in_transaction(...)
    result = nil
    ActiveRecord::Base.transaction { result = perform(...) }
    result
  end

  def ensure_result(result)
    return result if result.is_a?(Op::Lite::Result)

    success
  end

  def suppress_errors? = self.class.suppress_errors?

  def perform(*, **)
    raise NotImplementedError
  end
end
