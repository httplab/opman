# frozen_string_literal: true

module Op
  class Result
    attr_reader :success
    attr_reader :value
    attr_reader :error

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

    def fail?
      !success?
    end
  end
end
