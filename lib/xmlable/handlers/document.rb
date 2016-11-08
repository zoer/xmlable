module XMLable
  module Handlers
    #
    # Document class handles XML document
    #
    class Document < Base
      #
      # @param [Class] type
      #
      def initialize(type)
        @type = type
      end

      #
      # @see XMLable::Handler::Base#proxy
      #
      def proxy
        @type
      end

      #
      # Create document object from the XML document
      #
      # @param [Nokogiri::XML::Document] doc
      #
      # @return [XMLable::Mixins::Object]
      #
      def from_xml_document(doc)
        Builder.build_document(doc, self)
      end
    end
  end
end
