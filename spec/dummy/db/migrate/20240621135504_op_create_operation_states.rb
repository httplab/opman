# frozen_string_literal: true

class OpCreateOperationStates < ActiveRecord::Migration[7.1]
  def change
    create_table :operation_states do |t|
      t.string   :name
      t.jsonb    :context, null: false
      t.jsonb    :args, null: false

      # Emitter is who performed an Operation System or User, for example.
      # emitter_id is user_id in case when User initiated Operation.
      t.integer  :emitter_type, null: false, default: 0
      t.bigint   :emitter_id

      t.integer  :state, null: false, default: 0
      t.integer  :progress_pct, null: false, default: 0

      t.string   :error_kind
      t.string   :error_text
      t.string   :error_backtrace

      t.datetime :finished_at
      t.timestamps
    end
  end
end
