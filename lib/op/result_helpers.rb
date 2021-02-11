# frozen_string_literal: true

module Op
  module ResultHelpers
    include ActiveSupport::Concern

    def success(val = nil)
      Result.new(true, val)
    end

    def failure(error, val = nil, message: nil)
      result = Result.new(false, error)
      result.value = val
      result.message = message
      result
    end
  end
end
