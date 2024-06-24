module Op::Lite::Legacy
  extend ActiveSupport::Concern

  def operation_name
    self.class.operation_name
  end

  def current_calls_chain
    return operation_name unless parent

    [parent.current_calls_chain, operation_name].join('.')
  end

  def check_operation_name(*)
    true
  end

  class_methods do
    def operation_name(name = nil)
      @operation_name = check_operation_name(name) if name
      @operation_name ||= self.name.underscore.parameterize.underscore
    end

    def operation_name=(name)
      operation_name(name)
    end

    def check_operation_name(name)
      return if name =~ /^[a-z]+[a-z1-9_]+$/

      raise "Only alphanumeric and _ allowed for operation name"
    end
  end
end
