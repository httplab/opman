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

      it 'return success result' do
        op_result = do_call
        expect(op_result).to be_instance_of(::Op::Result)
        expect(op_result).to be_success
      end
    end
  end
end
