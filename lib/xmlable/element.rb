module XMLable
  #
  # Element module contains logic for standalone element object
  #
  module Element
    def self.included(base)
      base.send(:include, Mixins::Object)
      base.send(:include, Mixins::Castable)
      base.send(:include, Mixins::ElementsStorage)
      base.send(:include, Mixins::AttributesStorage)
      base.send(:include, Mixins::ContentStorage)
      base.send(:include, Mixins::StandaloneElement)
      base.send(:include, Mixins::OptionsStorage)
      base.send(:include, Mixins::NamespaceDefinitionsStorage)
      base.send(:include, Mixins::BareValue)
      base.send(:include, Mixins::Instantiable)
    end
  end
end
