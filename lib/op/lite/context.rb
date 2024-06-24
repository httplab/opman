class Op::Lite::Context
  def initialize(context = {})
    context.assert_valid_keys(:logger)

    @context = context
  end

  def [](key)
    @context[key]
  end

  def []=(key, value)
    @context[key] = value
  end

  def logger
    @context[:logger]
  end

  def to_json(_opts)
    JSON(as_json)
  end

  def as_json
    to_h
  end
end
