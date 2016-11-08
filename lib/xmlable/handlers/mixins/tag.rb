module XMLable
  module Handlers
    module Mixins
      #
      # Tag module contains tagable handlers
      #
      module Tag
        # @return [String] returns XML object tag name
        attr_reader :tag

        #
        # @see XMLable::Handler::Base#intialize
        #
        def initialize(*args, &block)
          super
          if args.last.is_a?(Hash)
            @tag = args.last.delete(:tag)
            @tag = @tag ? @tag.to_s : @name
          end
        end
      end
    end
  end
end
