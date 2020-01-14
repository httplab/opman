# frozen_string_literal: true

# You can add as much information into OperationContext as you want.
# Only one thing you need to keep in mind - methods :emitter_type,
# :emitter_id, :to_s, :to_h must be properly defined.
class OperationContext < Op::Context
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Check OperationState model to get full list of available emitters.
  def emitter_type
    :user
  end

  def emitter_id
    user.id
  end

  def to_s
    [:user, user.id, user.email].join(',')
  end

  def to_h
    {
      user_id: user.id,
      user_email: user.email
    }
  end
end
