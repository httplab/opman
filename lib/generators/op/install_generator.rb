# frozen_string_literal: true

require 'rails/generators/active_record'

module Op
  class InstallGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    def copy_operation_state_migration
      src = 'create_operation_states_migration.rb.erb'
      dst = 'db/migrate/op_create_operation_states.rb'
      migration_template(src, dst, migration_version: migration_version)
    end

    def copy_operation_state_model
      src = 'operation_state_model.rb'
      dst = "app/models/operation_state.rb"
      copy_file(src, dst)
    end

    def copy_operation_context_model
      src = 'operation_context_model.rb'
      dst = "app/models/operation_context.rb"
      copy_file(src, dst)
    end

    def migration_version
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end
  end
end
