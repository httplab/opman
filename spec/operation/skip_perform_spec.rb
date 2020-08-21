# frozen_string_literal: true

module OperationSkipPerformSpec
  describe 'Operation skip perform' do
    let(:user) { OpenStruct.new(id: 42, email: 'john.doe@foobar.com') }
    let(:operation_context) { OperationContext.new(user) }

    def do_call
      operation.call
    end

    context 'when skip_perform is set' do
      context 'when no steps added' do
        let(:operation) { EmptyOperation.new(operation_context) }
        class EmptyOperation < Op::Operation
          self.operation_name = 'empty_operation'
          skip_perform

          def perform(*); end
        end

        it 'doesnt call perform and raise error' do
          expect(operation).not_to receive(:perform)
          error_message = "Operation OperationSkipPerformSpec::EmptyOperation " \
                          "must have any step or doesnt skip perform method"
          expect { do_call }.to raise_error(error_message)
        end
      end

      context 'when step added' do
        let(:operation) { StepOperation.new(operation_context) }
        class StepOperation < Op::Operation
          self.operation_name = 'step_operation'
          skip_perform

          step :one

          def one(*); end

          def perform(*); end
        end

        it 'doesnt call perform' do
          expect(operation).to receive(:one).and_call_original
          expect(operation).not_to receive(:perform)
          do_call
        end
      end
    end

    context 'when skip_perform is not set' do
      context 'when no steps added' do
        let(:operation) { PerformOperation.new(operation_context) }
        class PerformOperation < Op::Operation
          self.operation_name = 'perform_operation'

          def perform(*)
            Op::Result.new(true)
          end
        end

        it 'doesnt call perform and raise error' do
          expect(operation).to receive(:perform).and_call_original
          do_call
        end
      end

      context 'when step added' do
        let(:operation) { StepPerformOperation.new(operation_context) }
        class StepPerformOperation < Op::Operation
          self.operation_name = 'step_perform_operation'

          step :one

          def one(*); end

          def perform(*)
            Op::Result.new(true)
          end
        end

        it 'doesnt call perform' do
          expect(operation).to receive(:one).and_call_original
          expect(operation).to receive(:perform).and_call_original
          do_call
        end
      end
    end
  end
end
