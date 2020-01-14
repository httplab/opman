# frozen_string_literal: true

class OperationContext < Op::Context
  attr_accessor :user_email

  def initialize(user_email)
    @user_email = user_email
  end

  def to_s
    user_email
  end

  def to_h
    {
      user_email: user_email
    }
  end
end

class Foo < Op::Operation
  self.operation_name = 'foo'

  def perform(name)
    Op::Result.new(true, "Hello, #{name}!")
  end
end

describe 'Tracking Operation State' do
  let(:operation_context) { OperationContext.new('john.doe@foobar.com') }
  let(:operation) { Foo.new(operation_context) }

  def do_call
    op.call('Alisa')
  end

  it 'creates operation state before execute #perform'
  it 'set state :finished when operation done'
  it 'set state :failed when error occurs'
end
