# frozen_string_literal: true

module Op
  module ResultHelpers
    include ActiveSupport::Concern

    def success(val = nil, opts = {})
      opts = opts.with_indifferent_access

      # For supporting nice short form
      #   success(name: 'John', email: 'john@example', value_accessors: true)
      value_accessors = opts[:value_accessors]
      value_accessors ||= val.delete(:value_accessors) if val.is_a?(Hash)

      Result.new(true, val, value_accessors: value_accessors)
    end

    def failure(error, val = nil, opts = {})
      opts = opts.with_indifferent_access

      message = opts[:message]
      value_accessors = opts[:value_accessors]

      # For supporting nice short form
      #   failure(:some_error, name: 'John', email: 'john@example', value_accessors: true)
      if val.is_a?(Hash)
        message ||= val.delete(:message)
        value_accessors ||= val.delete(:value_accessors)
      end

      result = Result.new(false, error, value_accessors: value_accessors)
      result.value = val
      result.message = message
      result
    end
  end
end
