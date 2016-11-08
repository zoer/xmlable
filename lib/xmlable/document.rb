module XMLable
  #
  # Document module contains logic for XML document object
  #
  module Document
    def self.included(base)
      base.include Mixins::Object
      base.include Mixins::Export
      base.include Mixins::OptionsStorage
      base.include Mixins::Instantiable
      base.include Mixins::Castable
      base.include Mixins::DocumentStorage
      base.include Mixins::RootStorage
    end
  end
end
