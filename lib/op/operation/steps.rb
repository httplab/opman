# frozen_string_literal: true

module Op
  module OperationSteps
    extend ActiveSupport::Concern

    class_methods do
      def step(name, opts = {})
        steps << [name, opts.symbolize_keys]
      end

      def each_step(&block)
        steps.each { |step| block.call(step[0], step[1]) }
      end

      private

      def steps
        @steps ||= []
      end
    end

    def steps
      self.class.instance_variable_get('@steps')
    end

    def steps_or_perform_defined?
      steps.present? || respond_to?(:perform)
    end

    def ensure_steps_or_perform
      return if steps_or_perform_defined?

      raise "Operation #{self.class.name} must have any step or perform method"
    end

    def run_perform?
      respond_to?(:perform) && steps.none? { |name, _opts| name == :perform }
    end

    def perform_steps(*args, **kwargs)
      result = Result.new(true)

      self.class.each_step do |name, opts|
        result = send(name, *args, **kwargs)
        result = Result.new(true, result) unless result.is_a?(Result)

        if result.fail?
          discard_state if opts[:discard_state_on_fail]
          break
        end
      end

      result
    end
  end
end
