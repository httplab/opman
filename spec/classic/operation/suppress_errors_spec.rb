# frozen_string_literal: true

module OperationSuppressErrorsSpec
  class Foo < Op::Operation
    operation_name 'foo'
    suppress_errors

    def perform
      raise 'something went wrong'
    end
  end

  describe 'supress errors' do
    let(:user) { OpenStruct.new(id: 42, email: 'john.doe@foobar.com') }
    let(:operation_context) { OperationContext.new(user: user) }
    let(:operation) { Foo.new(operation_context) }

    def do_call
      operation.call
    end

    it 'supresses an exception and returns failure' do
      # @type [Op::Result]
      result = nil

      expect { result = do_call }.to_not raise_error

      expect(result).to be_failure
      expect(result.error).to eq :exception
      expect(result.message).to eq 'something went wrong'
    end
  end
end
