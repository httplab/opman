# frozen_string_literal: true

module Op
  class Result
    class Unauthorized < Result
      def initialize(message)
        super(false)

        self.value = message
        self.error = :authorization
      end

      def message
        value
      end
    end
  end
end
