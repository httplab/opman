# frozen_string_literal: true

module OperationOptionalPerformSpec
  describe 'Operation skip perform' do
    let(:user) { OpenStruct.new(id: 42, email: 'john.doe@foobar.com') }
    let(:operation_context) { OperationContext.new(user) }

    def do_call
      operation.call
    end

    context 'when perform not defined' do
      context 'when no steps added' do
        let(:operation) { EmptyOperation.new(operation_context) }
        class EmptyOperation < Op::Operation
          self.operation_name = 'empty_operation'
        end

        it 'raise error' do
          error_message = "Operation OperationOptionalPerformSpec::EmptyOperation " \
                          "must have any step or perform method"
          expect { do_call }.to raise_error(error_message)
        end
      end

      context 'when step added' do
        let(:operation) { StepOperation.new(operation_context) }
        class StepOperation < Op::Operation
          self.operation_name = 'step_operation'

          step :one

          def one(*); end
        end

        it 'call step' do
          expect(operation).to receive(:one).ordered.and_call_original
          do_call
        end
      end
    end

    context 'when perform defined' do
      context 'when no steps added' do
        let(:operation) { PerformOperation.new(operation_context) }
        class PerformOperation < Op::Operation
          self.operation_name = 'perform_operation'

          def perform(*)
            Op::Result.new(true)
          end
        end

        it 'call perform' do
          expect(operation).to receive(:perform).and_call_original
          do_call
        end
      end

      context 'when step added' do
        context 'when perform is not step' do
          let(:operation) { PerformNotStepOperation.new(operation_context) }
          class PerformNotStepOperation < Op::Operation
            self.operation_name = 'perform_not_step_operation'

            step :one

            def one(*); end

            def perform(*)
              Op::Result.new(true)
            end
          end

          it 'call steps, then perform' do
            expect(operation).to receive(:one).ordered.and_call_original
            expect(operation).to receive(:perform).ordered.and_call_original
            do_call
          end
        end

        context 'when perform is step' do
          let(:operation) { PerformStepOperation.new(operation_context) }
          class PerformStepOperation < Op::Operation
            self.operation_name = 'perform_step_operation'

            step :perform
            step :one

            def one(*); end

            def perform(*)
              Op::Result.new(true)
            end
          end

          it 'call perform, then step' do
            expect(operation).to receive(:perform).ordered.and_call_original
            expect(operation).to receive(:one).ordered.and_call_original
            do_call
          end
        end
      end
    end
  end
end
