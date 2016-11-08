module XMLable
  #
  # Attribute module contains logic for standalone attribute object
  #
  module Attribute
    def self.included(base)
      base.include Mixins::Object
      base.include Mixins::Castable
      base.include Mixins::ValueStorage
      base.include Mixins::StandaloneAttribute
      base.include Mixins::OptionsStorage
      base.include Mixins::BareValue
      base.include Mixins::Instantiable
    end
  end
end
