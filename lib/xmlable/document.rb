module XMLable
  #
  # Document module contains logic for XML document object
  #
  module Document
    def self.included(base)
      base.send(:include, Mixins::Object)
      base.send(:include, Mixins::Export)
      base.send(:include, Mixins::OptionsStorage)
      base.send(:include, Mixins::Instantiable)
      base.send(:include, Mixins::Castable)
      base.send(:include, Mixins::DocumentStorage)
      base.send(:include, Mixins::RootStorage)
    end
  end
end
