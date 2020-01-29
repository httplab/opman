# frozen_string_literal: true

require 'ostruct'

class Foo < Op::Operation
  self.operation_name = 'foo'

  def perform(name, greeting:)
    Op::Result.new(true, "#{greeting}, #{name}!")
  end
end

describe 'Tracking Operation State' do
  let(:user) { OpenStruct.new(id: 42, email: 'john.doe@foobar.com') }
  let(:operation_context) { OperationContext.new(user) }
  let(:operation) { Foo.new(operation_context) }
  let(:operation_state) { operation.state }

  def do_call
    operation.call('Alice', greeting: 'Hello')
  end

  it 'creates operation state before execute #perform' do
    allow(operation).to receive(:success_state).and_return(true)

    do_call

    expect(OperationState.count).to eq 1
    expect(operation_state.name).to eq 'foo'
    expect(operation_state.context).to eq('user_id' => user.id, 'user_email' => user.email)
    expect(operation_state.args).to eq ['Alice', { 'greeting' => 'Hello' }]
    expect(operation_state.emitter_type).to eq 'user'
    expect(operation_state.emitter_id).to eq user.id
    expect(operation_state.state).to eq 'in_progress'
    expect(operation_state.created_at).to_not be_nil
    expect(operation_state.finished_at).to be_nil
  end

  it 'set state :finished when operation done' do
    result = do_call
    expect(result.value).to eq 'Hello, Alice!'

    expect(OperationState.count).to eq 1
    expect(operation_state.state).to eq 'success'
    expect(operation_state.finished_at).to_not be_nil
    expect(operation_state.progress_pct).to eq 100
  end

  it 'set state :failed when error occurs' do
    allow(operation).to receive(:perform).and_raise('Unexpected failure')

    expect { do_call }.to raise_error(RuntimeError, 'Unexpected failure')

    expect(OperationState.count).to eq 1
    expect(operation_state.state).to eq 'failed'
    expect(operation_state.finished_at).to_not be_nil
    expect(operation_state.error_text).to eq 'Unexpected failure'
    expect(operation_state.error_backtrace).to include('lib/op/operation.rb')
  end
end
