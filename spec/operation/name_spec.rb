# frozen_string_literal: true

module OperationNameSpec
  class PrintCallsChain < Op::Service
    def perform
      success(current_calls_chain)
    end
  end

  class Foo < Op::Operation
    def perform
      result = op(PrintCallsChain).call

      success(result.value)
    end
  end

  describe 'Operation Name' do
    let(:user) { OpenStruct.new(id: 42, email: 'john.doe@foobar.com') }
    let(:operation_context) { OperationContext.new(user) }
    let(:operation) { Foo.new(operation_context) }

    it 'raises error if format wrong' do
      msg = 'Operation name "1Wr0ngNa!Me" for "OperationNameSpec::Foo" '\
        'must contain only alphanumeric and underscore letters'
      expect { Foo.operation_name = '1Wr0ngNa!Me' }.to raise_error(RuntimeError, msg)
    end

    it 'must be present for operation' do
      msg = 'Operation name must be specified for OperationNameSpec::Foo'
      expect { operation.call }.to raise_error(RuntimeError, msg)
    end

    it 'op method should raise error if service does not have operation name' do
      allow(Foo).to receive(:operation_name).and_return('foo')

      msg = 'Operation name must be specified for OperationNameSpec::PrintCallsChain'
      expect { operation.call }.to raise_error(RuntimeError, msg)
    end

    it 'chains operation name when call nested services' do
      allow(Foo).to receive(:operation_name).and_return('foo')
      allow(PrintCallsChain).to receive(:operation_name).and_return('print_calls_chain')

      result = operation.call
      expect(result.value).to eq 'foo.print_calls_chain'
    end
  end
end
