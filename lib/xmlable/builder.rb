module XMLable
  #
  # Builder class builds object that represents XML attribute and values
  #
  class Builder
    include Singleton

    class << self
      #
      # Build document object from XML document
      #
      # @param [Nokogiri::XML::Document] document
      # @param [XMLable::Handlers::Document] handler
      #
      # @return [XMLable::Mixins::Object]
      #
      def build_document(document, handler)
        obj = handler.proxy.new({}, document, handler)
        populate_document(obj, document)
      end

      #
      # Build attribute object from XML attribute
      #
      # @param [Nogogiri::XML::Attribute] attribute
      # @param [XMLable::Handlers::Base] handler
      #
      # @return [XMLable::Mixins::Object]
      #
      def build_attribute(attribute, handler)
        obj = handler.proxy.new({}, attribute, handler)
        populate_attribute(obj, attribute)
      end

      #
      # Build element object from XML element
      #
      # @param [Nogogiri::XML::Element] node
      # @param [XMLable::Handlers::Base] handler
      #
      # @return [XMLable::Mixins::Object]
      #
      def build_element(node, handler)
        obj = handler.proxy.new({}, node, handler)
        populate_element(obj, node)
      end

      #
      # Populate document object
      #
      # @param [XMLable::Mixins::Object] obj
      # @param [Nogogiri::XML::Document] node
      #
      # @return [XMLable::Mixins::Object]
      #
      def populate_document(obj, node)
        obj.__set_root(node.root)
        obj
      end

      #
      # Populate element object
      #
      # @param [XMLable::Mixins::Object] obj
      # @param [Nogogiri::XML::Element] node
      #
      # @return [XMLable::Mixins::Object]
      #
      def populate_element(obj, node)
        node.namespace_definitions.each { |ns| obj.__set_namespace_definition(ns) }
        node.elements.each { |el| obj.__set_element(el) }
        node.attributes.each { |_, att| obj.__set_attribute(att) }
        obj.__set_content(node)
        obj
      end

      #
      # Populate attribute object
      #
      # @param [XMLable::Mixins::Object] obj
      # @param [Nogogiri::XML::Attr] node
      #
      # @return [XMLable::Mixins::Object]
      #
      def populate_attribute(obj, node)
        obj.tap { |o| o.__set_value(node) }
      end

      #
      # Find defined type
      #
      # @param [Object] type
      #
      # @return [Class] returns found type or define new one if it's not found
      #
      def find_type(type)
        type = type.to_s if type.is_a?(Symbol)
        klass = instance.defined_types[type]
        klass ? klass : define_type(type)
      end

      #
      # Wrap type with additional logic
      #
      # @param [Class] klass
      #
      # @return [Class] returns wrapped class
      #
      def wrap_type(klass, &block)
        Class.new do
          include Mixins::Object
          include Mixins::Wrapper
          include Mixins::Castable
          include Mixins::OptionsStorage
          class_eval(&block) if block_given?
        end
      end

      #
      # Inherit type and set additional settings
      #
      # @param [Class] klass
      #
      # @return [Class] returns wrapped class
      #
      def inherit_type(klass, &block)
        Class.new(klass) do
          class_eval(&block) if block_given?
        end
      end

      #
      # Define new type
      #
      # @param [Array<Object>] names type's names(aliases)
      #
      # @return [Class]
      #
      def define_type(*names, &block)
        names = names.map { |n| n.is_a?(Symbol) ? n.to_s : n }
        main = names.first
        klass = wrapped_type?(main) ? wrap_type(main, &block) : inherit_type(main, &block)
        names.each { |n| instance.defined_types[n] = klass }
        klass
      end

      #
      # Is the given class wrapped?
      #
      # @return [Boolean]
      #
      def wrapped_type?(klass)
        return true  if !klass.is_a?(Class)
        return false if klass.ancestors.include?(Mixins::StandaloneElement)
        return false if klass.ancestors.include?(Mixins::StandaloneAttribute)
        true
      end

      #
      # Get proxy for the given type
      #
      # @param [Object] type type's name
      #
      # @return [Class] returns type's proxy class
      #
      def proxy_for(type)
        find_type(type).dup
      end

      #
      # Get container proxy for the given class
      #
      # @param [Class] klass
      #
      # @return [Class]
      #
      def container_proxy_for(klass)
        Class.new(klass) { include Mixins::Container }
      end
    end

    # @return [Hash]
    attr_reader :defined_types

    def initialize
      @defined_types = {}
    end
  end
end
