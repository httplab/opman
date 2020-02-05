# frozen_string_literal: true

module Op
  class Operation < Service
    attr_reader :state

    def initialize(context)
      super
    end

    class << self
      def step(name, opts = {})
        steps << [name, opts.symbolize_keys]
      end

      def each_step(&block)
        steps.each { |step| block.call(step[0], step[1]) }
      end

      def call(context, *args)
        operation = new(context)
        operation.perform(*args)
      end

      private

      def steps
        @steps ||= []
      end
    end

    def call(*args)
      check_operation_name(self.class, operation_name)

      prepare_state(args)

      result = perform_steps(*args)
      if result.fail?
        fail_state_with_result(result)
        return result
      end

      result = perform(*args)
      ensure_result(result)

      success_state

      result
    rescue StandardError => err
      fail_state_with_error(err)

      raise
    end

    private

    def prepare_state(args)
      @state = OperationState.create!(
        name: operation_name,
        context: context.as_json,
        args: args,
        emitter_type: context.emitter_type,
        emitter_id: context.emitter_id
      )
    end

    def perform_steps(*args)
      result = Result.new(true)

      self.class.each_step do |name, opts|
        result = send(name, *args)
        result = Result.new(true, result) unless result.is_a?(Result)

        if result.fail?
          discard_state if opts[:discard_state_on_fail]
          break
        end
      end

      result
    end

    def discard_state
      return unless @state

      @state.delete
    end

    def success_state
      @state.update!(state: 'success', finished_at: Time.current, progress_pct: 100)
    end

    def ensure_result(result)
      err = %(Operation must return "Op::Result" or inherited (Recieved "#{result.class}"))
      raise err unless result.class <= Op::Result
    end

    def fail_state_with_error(err)
      return unless @state

      @state.update!(state: 'failed', finished_at: Time.current, error_text: err.message,
                     error_backtrace: err.backtrace.join("\n"))
    end

    def fail_state_with_result(_result)
      return unless @state
    end
  end
end
