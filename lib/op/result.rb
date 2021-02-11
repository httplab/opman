# frozen_string_literal: true

module Op
  class Result
    # Extend this class by result helpers to provide nice factory methods Op::Result.success
    # and Op::Result.failure, it useful in tests.
    extend ResultHelpers

    attr_reader :success
    attr_reader :value
    attr_accessor :error
    attr_writer :message

    def initialize(success, value_or_error = nil)
      @success = success

      if success?
        @value = value_or_error
        generate_value_accessors
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
    alias failed? fail?
    alias failure? fail?

    def message
      @message || default_message
    end

    def value=(val)
      @value = val
      generate_value_accessors
    end

    private

    def default_message
      return 'Success' if success?

      "Failure, #{error}"
    end

    # Define some sugar to easily access value using [] or accessors named as a hash keys
    def generate_value_accessors
      return unless value.respond_to?(:[])

      define_singleton_method(:[]) do |key|
        value[key]
      end

      return unless value.is_a?(Hash)

      value.each do |key, _|
        str_key = key.to_s

        # We don't need to generate method for existing accessor just set instance variable.
        # And we don't want to override message which was explicitly set, so we use ||= operator.
        if str_key == 'message'
          @message ||= value[key]
          next
        end

        next unless str_key =~ /^[a-z_]+[a-z0-9_]*$/

        define_singleton_method(key) do
          value[key]
        end
      end
    end
  end
end
