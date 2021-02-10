# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class OperationState < ActiveRecord::Base
  enum emitter_type: { system: 0, user: 1 }
  enum state: { in_progress: 0, success: 1, failed: 2 }
end
# rubocop:enable Rails/ApplicationRecord
