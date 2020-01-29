# frozen_string_literal: true

module OperationResultSpec
  class Foo < Op::Operation
    self.operation_name = 'foo'

    def perform(result)
      result
    end
  end

  describe 'Operation Result' do
    let(:user) { OpenStruct.new(id: 42, email: 'john.doe@foobar.com') }
    let(:operation_context) { OperationContext.new(user) }
    let(:operation) { Foo.new(operation_context) }

    def do_call
      operation.call(result)
    end

    context 'when result is Op::Result' do
      let(:result) { ::Op::Result.new(true) }

      it { expect(do_call).to eq(result) }
    end

    context 'when result is Integer' do
      let(:result) { 1 }

      it 'raise error' do
        msg = <<~MSG
          Operation must return "Op::Result" or inherited (Recieved "Integer")
        MSG
        expect { do_call }.to raise_error(RuntimeError, msg)
      end
    end
  end
end
