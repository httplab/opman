# frozen_string_literal: true

module Op
  class Result
    class Forbidden < Result
      def initialize(message)
        super(false, :authorization)
        self.value = message
      end

      def message
        value
      end
    end
  end
end
