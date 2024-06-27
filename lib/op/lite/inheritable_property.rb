module Op::Lite::InheritableProperty
  extend ActiveSupport::Concern

  class_methods do
    def inheritable_property_set(name, value)
      instance_variable_set("@#{name}", value)
    end

    def inheritable_property_get(name)
      if instance_variable_defined?("@#{name}")
        instance_variable_get("@#{name}")
      elsif superclass.respond_to?(:inheritable_property_get)
        superclass.inheritable_property_get(name)
      end
    end
  end
end
