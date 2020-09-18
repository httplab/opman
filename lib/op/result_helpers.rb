# frozen_string_literal: true

module Op
  module ResultHelpers
    include ActiveSupport::Concern

    def success(val = nil)
      Result.new(true, val)
    end

    def failure(error, message = nil, val: nil)
      result = Result.new(false, error)
      result.message = message
      result.value = val
      result
    end
  end
end
