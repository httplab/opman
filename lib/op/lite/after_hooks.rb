module Op::Lite::AfterHooks
  extend ActiveSupport::Concern

  class_methods do
    def after(method_name, on: nil)
      @after_hooks ||= []
      @after_hooks << { method_name: method_name, on: on }
    end
  end

  def run_after_hooks(result)
    return if after_hooks.nil? || after_hooks.empty?

    after_hooks.each do |hook|
      hook_result = send(hook[:method_name], result) if hook[:on].nil? || result.send("#{hook[:on]}?")
      return hook_result if hook_result.respond_to?(:failure?) && hook_result.failure?
    end
  end

  def after_hooks
    self.class.instance_variable_get(:@after_hooks)
  end
end
