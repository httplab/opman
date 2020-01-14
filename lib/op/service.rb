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

    def perform(*_args)
      raise 'Not implemented yet'
    end

    def operation_name
      self.class.operation_name
    end
  end
end
