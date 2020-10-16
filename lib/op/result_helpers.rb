# frozen_string_literal: true

module Op
  module ResultHelpers
    include ActiveSupport::Concern

    def success(val = nil)
      Result.new(true, val)
    end

    def failure(error, value = nil, message: nil)
      result = Result.new(false, error)
      result.value = value
      result.message = message
      result
    end
  end
end
