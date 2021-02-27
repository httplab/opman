# frozen_string_literal: true

require_relative './operation/steps'

module Op
  class Operation < Service
    include OperationSteps

    attr_reader :state

    class << self
      def call(context, *args, **kwargs)
        operation = new(context)
        operation.call(*args, **kwargs)
      end
    end

    def call(*args, **kwargs)
      check_operation_name(self.class, operation_name)
      ensure_steps_or_perform

      prepare_state(args, kwargs)

      result = perform_steps(*args, **kwargs)
      if result.fail?
        fail_state_with_result(result)
        return result
      end

      result = super(*args, **kwargs) if run_perform?

      if result.fail?
        fail_state_with_result(result)
      else
        success_state
      end

      result
    rescue StandardError => e
      fail_state_with_error(e)

      raise
    end

    private

    def prepare_state(args, kwargs)
      @state = OperationState.create!(
        name: operation_name,
        context: context.as_json,
        args: safe_args(args, kwargs),
        emitter_type: context.emitter_type,
        emitter_id: context.emitter_id
      )
    end

    # rubocop:disable Layout/LineLength
    # There is convention to not pass complex data types in args but sometimes when we need to
    # handle ActionController::Parameters it may contain ActionDispatch::Http::UploadedFile which is
    # not always can be correctly serialized into JSON. Sometimes it raises Encoding::UndefinedConversionError
    # because of special characters in headers field. If this happens we catch error and just dump
    # entire args as string to debug purpose.
    # This is example of broken args:
    # => {"image"=>
    #   #<ActionDispatch::Http::UploadedFile:0x0000564a0dfa0b60
    #    @content_type="image/jpeg",
    #    @headers=
    #     "Content-Disposition: form-data; name=\"website_image[image]\"; filename=\"httplab \xD0\xBB\xD0\xBE\xD0\xB3\xD0\xBE\xD1\x82\xD0\xB8\xD0\xBF.jpg\"\r\nContent-Type: image/jpeg\r\n",
    #    @original_filename="httplab логотип.jpg",
    #    @tempfile=#<File:/tmp/RackMultipart20200502-18311-ra5vtv.jpg>>}
    def safe_args(args, kwargs)
      target = args
      target += [kwargs] if kwargs.present?

      # Try to convert args to JSON to emit Encoding::UndefinedConversionError
      target.to_json

      # return args if there is no error
      target.as_json
    rescue Encoding::UndefinedConversionError
      # Otherwise return special hash with args dumped into string
      { '_' => target.inspect }
    end
    # rubocop:enable Layout/LineLength

    def discard_state
      return unless @state

      @state.delete
      @state = nil
    end

    def success_state
      @state.update!(state: 'success', finished_at: Time.current, progress_pct: 100)
    end

    def fail_state_with_error(err)
      return unless @state

      @state.update!(state: 'failed', finished_at: Time.current, error_kind: :exception,
                     error_text: err.message, error_backtrace: err.backtrace.join("\n"))
    end

    def fail_state_with_result(result)
      return unless @state

      @state.update!(state: 'failed', finished_at: Time.current, error_kind: result.error.to_sym,
                     error_text: result.message)
    end
  end
end
