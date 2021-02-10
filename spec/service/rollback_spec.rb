# frozen_string_literal: true

module ServiceRollbackSpec
  class FailureService < Op::Service
    operation_name 'failure_service'
    transactional

    def perform
      failure(:error)
    end
  end

  class ParentService < Op::Service
    operation_name 'parent'
    transactional

    def perform
      op(ChildService).call
      success
    end
  end

  class ChildService < Op::Service
    operation_name 'child'
    transactional

    def perform
      failure(:error)
    end
  end

  describe 'Rollback transactional services' do
    context 'when top level #perform return failure' do
      let(:service) { FailureService.new }

      it 'rollback transaction' do
        expect(ActiveRecord::Rollback).to receive(:new)
          .and_call_original

        expect { service.call }.not_to raise_error
      end
    end

    context 'when nested #perform return failure' do
      let(:service) { ParentService.new }

      it 'successfully perform operation' do
        expect(ActiveRecord::Rollback).not_to receive(:new)

        expect { service.call }.not_to raise_error
      end
    end
  end
end
