module XMLable
  module Handlers
    class Element < Base
      include Mixins::Namespace
      include Mixins::Described
      include Mixins::Tag

      #
      # @see XMLable::Handler::Base#initialize
      #
      def initialize(name, opts = {}, &block)
        @container_type = opts.delete(:container) || Array
        super(name, opts, &block)
      end

      #
      # Proxy class for elements objects
      #
      # @return [Class]
      #
      def container_proxy
        @container_proxy ||= Builder.container_proxy_for(@container_type)
      end

      #
      # Create elements container for XML element
      #
      # @parent [Nokogiri::XML::Element]
      #
      # @return [#each]
      #
      def container_for_xml_element(parent)
        container_proxy.new.tap do |c|
          c.__set_parent_node(parent)
          c.__set_handler(self)
        end
      end

      #
      # @see XMLable::Handler::Base#inject_wraped
      #
      def inject_wraped(klass)
        klass.class_eval do
          include XMLable::Mixins::ContentStorage
          include XMLable::Mixins::AttributesStorage
          include XMLable::Mixins::ElementsStorage
          include XMLable::Mixins::NamespaceDefinitionsStorage
          include XMLable::Mixins::BareValue
          include XMLable::Mixins::Instantiable
        end
        klass
      end

      #
      # @see XMLable::Handler::Base#proxy
      #
      def proxy
        @proxy ||= type_class.tap do |p|
          p.__default_namespace = namespace_prefix
          p.class_eval(&@block) if block_settings?
        end
      end

      #def dynamic?
        #@block != nil
      #end

      #
      # Is this handler for multiple elements objects or not?
      #
      # @return [Boolean]
      #
      def single?
        true
      end

      #
      # Create element object from the XML element
      #
      # @param [Nokogiri::XML::Element] element
      #
      # @return [XMLable::Mixins::Object]
      #
      def from_xml_element(element)
        Builder.build_element(element, self)
      end
    end
  end
end
