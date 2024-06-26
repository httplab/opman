# frozen_string_literal: true

require 'simplecov'
SimpleCov.minimum_coverage 100
SimpleCov.start

ENV['RAILS_ENV'] = 'test'

require_relative "../spec/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.example_status_persistence_file_path = "tmp/examples.txt"
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    unless ENV['SKIP_CREATE_SUITE'] == 'true'
      system('./install_dummy.sh')
      require './spec/dummy/app/models/operation_context'
      require './spec/dummy/app/models/operation_state'
    end
  end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.after(:suite) do
    system('./cleanup_dummy.sh') unless ENV['SKIP_CLEAN_SUITE'] == 'true'
  end
end
