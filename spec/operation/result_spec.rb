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
        msg = %(Operation must return "Op::Result" or inherited (Recieved "Integer"))
        expect { do_call }.to raise_error(RuntimeError, msg)
      end
    end
  end

  describe 'Value accessors' do
    describe 'when value is array' do
      shared_examples 'array examples' do
        it 'delegates []' do
          expect(result[0]).to eq('Hello world')
          expect(result[1]).to eq(123)
        end
      end

      let(:data) { ['Hello world', 123] }

      context 'success' do
        let(:result) { Op::Result.success(data, value_accessors: true) }

        include_examples 'array examples'
      end

      context 'failure' do
        let(:result) { Op::Result.failure(:funny_error, data, message: 'Say hello!', value_accessors: true) }

        include_examples 'array examples'
      end
    end

    describe 'when value is hash' do
      shared_examples 'hash examples' do
        it 'delegates []' do
          expect(result[:str_prop]).to eq('Hello world')
          expect(result[:num_prop]).to eq(123)
          expect(result[42]).to eq('wrong key')
        end

        it 'generates accessors' do
          expect(result.str_prop).to eq('Hello world')
          expect(result.num_prop).to eq(123)

          # It skips key 123 because it is wrong method name
        end
      end

      let(:args) do
        {
          str_prop: 'Hello world',
          num_prop: 123,
          42 => 'wrong key',
          message: 'Message from data!',
          value_accessors: true
        }
      end

      context 'success' do
        let(:result) { Op::Result.success(args) }

        include_examples 'hash examples'

        it 'returns message from data' do
          expect(result.message).to eq 'Message from data!'
        end
      end

      context 'failure' do
        let(:result) { Op::Result.failure(:funny_error, args, message: 'Message from failure result options!', value_accessors: true) }

        include_examples 'hash examples'

        it 'returns explicit message from result options' do
          expect(result.message).to eq 'Message from failure result options!'
        end
      end
    end
  end
end
