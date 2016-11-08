module XMLable
  module Handlers
    #
    # Elements handles group of XML elements
    #
    class Elements < Element
      #
      # @see XMLable::Handlers::Element#single?
      #
      def single?
        false
      end
    end
  end
end
