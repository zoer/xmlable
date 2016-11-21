module XMLable
  module Mixins
    #
    # StandaloneAttribute module contains standalone attribute's logic
    #
    module StandaloneAttribute
      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      module ClassMethods
        #
        # Describe attribute name/tag
        #
        # @param [String, Symbol] tag
        #
        def attr_name(tag)
          @__tag = tag.to_s
        end

        #
        # Get attribute name/tag
        #
        # @api private
        #
        # @return [String]
        #
        def __tag
          @__tag
        end
      end
    end
  end
end
