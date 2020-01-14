# frozen_string_literal: true

module Op
  class Service
    attr_reader :context
    attr_reader :parent

    class << self
      attr_reader :operation_name

      def operation_name=(name)
        raise 'Operation name must contain only alphanumeric and underscore letters' unless name =~ /^\w+$/

        @operation_name = name.downcase
      end
    end

    def initialize(context = nil, parent = nil)
      @context = context
      @parent = parent
    end

    def self.call(*args)
      service = new
      service.perform(*args)
    end

    # :nocov:
    def perform(*_args)
      raise 'Not implemented yet'
    end
    # :nocov:

    def operation_name
      self.class.operation_name
    end

    def op(target_class, *args)
      target_class.new(context, self).call(*args)
    end

    # Use it if you need to do something immediately.
    def op!(target_class, *args)
      op(target_class, *args)
    end
  end
end
