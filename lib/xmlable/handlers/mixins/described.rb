module XMLable
  module Handlers
    module Mixins
      #
      # Described module contains described and null object handlers logic
      #
      module Described
        #
        # Is this handlers described by user or not?
        #
        # @return [Boolean]
        #
        def described?
          !self.class.name.end_with?('None')
        end
      end
    end
  end
end
