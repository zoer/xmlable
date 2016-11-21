module XMLable
  module Mixins
    #
    # StandaloneElement module contains standalone element's logic
    #
    module StandaloneElement
      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      #
      # @param [Nokogiri::XML::Element] node XML element
      # @param [XMLable::Handlers::Document] handler element's handler
      #
      def initialize(node = nil, handler = nil)
        unless node
          doc = Nokogiri::XML::Document.new
          node = Nokogiri::XML::Element.new(self.class.__tag, doc)
        end
        handler = self.class.__standalone_element_handler unless handler
        super
      end

      module ClassMethods
        #
        # Describe element's tag name
        #
        # @param [String, Symbol] name
        #
        def tag(name)
          @__tag = name.to_s
        end

        #
        # Get tag name
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
