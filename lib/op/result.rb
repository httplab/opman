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
    attr_accessor :value_accessors

    # Arguments is a bit messy but we want to keep it for backward compatibility for a while.
    # Set value_accessors: true if you want to generate methods for keys in case if value is a hash.
    # It can be useful if you need to return more than one value with result, for example:
    #   result = Op::Result.new(true, user: 'John', email: 'john@example.org', value_accessors: true)
    #   result.user  # => John
    #   result.email # => john@example.org
    def initialize(success, value_or_error = nil)
      value_accessors = false
      value_accessors = value_or_error[:value_accessors] || false if value_or_error.is_a?(Hash)

      @value_accessors = value_accessors
      @success = success

      if success?
        @value = value_or_error
        generate_value_accessors if @value_accessors
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
      generate_value_accessors if @value_accessors
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

        next if str_key == 'value_accessors'
        next unless str_key =~ /^[a-z_]+[a-z0-9_]*$/

        # We don't want to override existing result methods, so we raise error in case
        # of names conflict.
        raise "Method '#{key}' is already defined" if respond_to?(key)

        define_singleton_method(key) do
          value[key]
        end
      end
    end
  end
end
