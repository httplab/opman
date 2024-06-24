class OperationContext < Op::Context
  attr_reader :user, :organization, :logger

  def initialize(context = {})
    context.assert_valid_keys(:logger, :user, :organization, :emitter_type)

    @context = context
    @user = context[:user]
    @organization = context[:organization]
    @logger = context[:logger]
  end

  def emitter_id
    user&.id
  end

  def emitter_type
    return :system if user.nil?
    :user
  end

  def to_json(_opts)
    JSON(as_json)
  end

  def as_json
    to_h
  end

  def to_h
    {
      emitter_type:,
      user_id: user&.id,
      user_email: user&.email
    }.compact
  end
end
