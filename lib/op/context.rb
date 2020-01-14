# frozen_string_literal: true

module Op
  class Context < Service
    def to_s
      raise 'Not implemented'
    end

    def to_h
      raise 'Not implemented'
    end

    def to_json(_opts)
      JSON(as_json)
    end

    def as_json
      to_h
    end
  end
end
