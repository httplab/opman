# frozen_string_literal: true

module Op
  class Service
    OPERATION_NAME_REGEX = /^[a-z]+[a-z1-9_]+$/.freeze

    attr_reader :context
    attr_reader :parent

    class << self
      attr_reader :operation_name

      def operation_name=(name)
        check_operation_name(self, name)
        @operation_name = name
      end
    end

    def initialize(context = nil, parent = nil)
      @context = context
      @parent = parent
    end

    def self.call(*args)
      service = new
      service.call(*args)
    end

    def call(*args)
      perform(*args)
    end

    # :nocov:
    def perform(*_args)
      raise 'Not implemented yet'
    end
    # :nocov:

    def operation_name
      self.class.operation_name
    end

    def current_calls_chain
      return operation_name unless parent

      [parent.current_calls_chain, operation_name].join('.')
    end

    def self.check_operation_name(target_class, name)
      if name.blank?
        err = 'Operation name must be specified for ' + target_class.name
        raise err
      end

      return if name =~ OPERATION_NAME_REGEX

      err = "Operation name \"#{name}\" for \"#{target_class.name}\" must "\
        "contain only alphanumeric and underscore letters"
      raise err
    end

    def check_operation_name(target_class, name)
      self.class.check_operation_name(target_class, name)
    end

    def op(target_class, *args)
      check_operation_name(target_class, target_class.operation_name)
      target_class.new(context, self).call(*args)
    end

    # Use it if you need to do something immediately.
    def op!(target_class, *args)
      op(target_class, *args)
    end
  end
end
