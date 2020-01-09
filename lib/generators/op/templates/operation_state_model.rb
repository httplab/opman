# frozen_string_literal: true

class OperationState
  enum emitter_type: { system: 0, user: 1 }
  enum state: { pending: 0, in_progress: 1, finished: 2, failed: 3 }
end
