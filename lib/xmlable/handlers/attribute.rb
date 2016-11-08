module XMLable
  module Handlers
    #
    # Attribute handles XML attributes objects
    #
    class Attribute < Base
      include Mixins::Namespace
      include Mixins::Described
      include Mixins::Tag

      #
      # @see XMLable::Handler::Base#inject_class
      #
      def inject_wraped(klass)
        klass.class_eval do
          include XMLable::Mixins::ValueStorage
          include XMLable::Mixins::Instantiable
        end
        klass
      end

      #
      # @see XMLable::Handler::Base#proxy
      #
      def proxy
        @proxy ||= type_class.tap { |a| a.class_eval(&@block) if block_settings?  }
      end

      #
      # Create attribute object from the XML attribute
      #
      # @param [Nokogiri::XML::Attr] attribute
      #
      # @return [XMLable::Mixins::Object]
      #
      def from_xml_attribute(attribute)
        Builder.build_attribute(attribute, self)
      end
    end
  end
end
