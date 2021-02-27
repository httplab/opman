# frozen_string_literal: true

# You can add as much information into OperationContext as you want.
# Only one thing you need to keep in mind - methods :emitter_type,
# :emitter_id, :to_s, :to_h must be properly defined.
class OperationContext < Op::Context
  attr_reader :user, :emitter_type

  def initialize(user = nil, emitter_type: :system)
    super()

    @user = user
    @emitter_type = emitter_type
  end

  def self.system
    OperationContext.new(nil, emitter_type: :system)
  end

  def self.user(user)
    OperationContext.new(user, emitter_type: :user)
  end

  def emitter_id
    user&.id
  end

  def system?
    emitter_type == :system
  end

  def to_s
    if system?
      'system'
    else
      [:user, user.id, user.email].join(',')
    end
  end

  def to_h
    {
      emitter_type: emitter_type,
      user_id: user&.id,
      user_email: user&.email
    }.compact
  end
end
