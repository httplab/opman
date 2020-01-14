# frozen_string_literal: true

module Op
  class Operation < Service
    attr_reader :operation_state

    def initialize(context)
      super
    end

    def call(*args)
      perform(*args)
    rescue StandardError => e
      raise e
    end
  end
end
