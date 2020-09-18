# frozen_string_literal: true

module Op
  class Result
    attr_reader :success
    attr_accessor :value
    attr_accessor :error
    attr_writer :message

    def initialize(success, value_or_error = nil)
      @success = success

      if success?
        @value = value_or_error
      else
        @error = value_or_error
      end
    end

    def success?
      success
    end

    def fail?(reason = nil)
      !success? && (!reason || reason == error)
    end

    def message
      @message || default_message
    end

    private

    def default_message
      return 'Success' if success?

      "Failure, #{error}"
    end
  end
end
