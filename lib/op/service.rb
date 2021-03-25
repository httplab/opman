# frozen_string_literal: true

module Op
  class Service
    include ResultHelpers

    OPERATION_NAME_REGEX = /^[a-z]+[a-z1-9_]+$/.freeze

    attr_reader :context
    attr_reader :parent

    class << self
      def operation_name(new_name = nil)
        return @operation_name unless new_name

        self.operation_name = new_name
      end

      def operation_name=(name)
        check_operation_name(self, name)
        @operation_name = name
      end

      def transactional
        @transactional = true
      end

      def transactional?
        @transactional == true
      end
    end

    def initialize(context = nil, parent = nil)
      @context = context
      @parent = parent
    end

    def self.call(*args, **kwargs)
      service = new
      service.call(*args, **kwargs)
    end

    def call(*args, **kwargs)
      if perform_in_transaction?
        perform_in_transaction(*args, **kwargs)
      else
        run_perform(*args, **kwargs)
      end
    end

    def run_perform(*args, **kwargs)
      ensure_result(perform(*args, **kwargs))
    end

    def perform_in_transaction(*args, **kwargs)
      result = nil
      ActiveRecord::Base.transaction do
        result = run_perform(*args, **kwargs)
      end
      result
    end
    # :nocov:

    def ensure_result(result)
      return result if result.class <= Op::Result

      success
    end

    def operation_name
      self.class.operation_name
    end

    def current_calls_chain
      return operation_name unless parent

      [parent.current_calls_chain, operation_name].join('.')
    end

    def self.check_operation_name(target_class, name)
      if name.blank?
        err = "Operation name must be specified for #{target_class.name}"
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

    def perform_in_transaction?
      !parent_performed_in_transaction? && self.class.transactional?
    end

    def parent_performed_in_transaction?
      return false if parent.blank?

      parent.perform_in_transaction?
    end

    def op(target_class)
      check_operation_name(target_class, target_class.operation_name)
      target_class.new(context, self)
    end

    # Use it if you need to do something immediately.
    def op!(target_class)
      op(target_class)
    end

    # TODO: Setup proper logger
    def logger
      Rails.logger
    end
  end
end
