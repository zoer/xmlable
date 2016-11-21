module XMLable
  #
  # Attribute module contains logic for standalone attribute object
  #
  module Attribute
    def self.included(base)
      base.send(:include, Mixins::Object)
      base.send(:include, Mixins::Castable)
      base.send(:include, Mixins::ValueStorage)
      base.send(:include, Mixins::StandaloneAttribute)
      base.send(:include, Mixins::OptionsStorage)
      base.send(:include, Mixins::BareValue)
      base.send(:include, Mixins::Instantiable)
    end
  end
end
