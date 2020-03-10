# frozen_string_literal: true

module Op
  class Result
    class ValidationFail < Result
      ValidationError = Struct.new(:source, :error, :details, :value) do
        def to_s
          msg = "#{source} is #{error} it #{details}"
          msg += " (given \"#{value}\")" if value
          msg
        end

        def as_json
          to_h
        end

        def to_json(_)
          JSON(to_h)
        end
      end

      def initialize(value)
        super(false, :validation)

        self.value = value
        gather_am_errors
      end

      def add(src, error, error_details, value = nil)
        details << ValidationError.new(src.to_sym, error.to_sym, error_details, value)
      end

      def details
        @details ||= []
      end

      def message
        details.map(&:to_s).join(', ')
      end

      private

      def gather_am_errors
        return unless value.is_a?(ActiveModel::Validations)

        value.errors.details.each do |k, errors|
          err_src = k.to_sym

          errors.each_with_index do |error, idx|
            err_kind = error[:error]

            if error[:value]
              if error[:value].is_a?(Hash)
                err_val = error[:value][err_src]
              else
                err_val = error[:value]
              end
            end

            err_details = value.errors[err_src][idx]

            add(err_src, err_kind, err_details, err_val)
          end
        end
      end
    end
  end
end
