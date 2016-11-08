module XMLable
  #
  # Element module contains logic for standalone element object
  #
  module Element
    def self.included(base)
      base.include Mixins::Object
      base.include Mixins::Castable
      base.include Mixins::ElementsStorage
      base.include Mixins::AttributesStorage
      base.include Mixins::ContentStorage
      base.include Mixins::StandaloneElement
      base.include Mixins::OptionsStorage
      base.include Mixins::NamespaceDefinitionsStorage
      base.include Mixins::BareValue
      base.include Mixins::Instantiable
    end
  end
end
