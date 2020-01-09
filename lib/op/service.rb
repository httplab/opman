# frozen_string_literal: true

module Op
  class Service
    attr_reader :context

    def initialize(context = nil)
      @context = context
    end

    def self.call(*args)
      service = new
      service.perform(*args)
    end

    def perform(*_args)
      raise 'Not implemented yet'
    end
  end
end
