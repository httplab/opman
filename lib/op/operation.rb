# frozen_string_literal: true

module Op
  class Operation < Service
    attr_reader :state

    def initialize(context)
      super
    end

    def call(*args)
      prepare_state(args)
      result = perform(*args)
      success_state

      result
    rescue StandardError => err
      fail_state(err)

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

    def success_state
      @state.update!(state: 'success', finished_at: Time.current, progress_pct: 100)
    end

    def fail_state(err)
      @state.update!(state: 'failed', finished_at: Time.current, error_text: err.message,
                     error_backtrace: err.backtrace.join("\n"))
    end
  end
end
