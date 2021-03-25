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
end
