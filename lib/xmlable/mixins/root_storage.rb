module XMLable
  module Mixins
    #
    # RootStorage module contains the logic to manage with XML root element
    #
    module RootStorage
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Set XML root element
      #
      # @param [Nokogiri::XML::Element, nil] node
      #
      def __set_root(node)
        unless node.is_a?(Nokogiri::XML::Element)
          node = Nokogiri::XML::Element.new(__root_handler.tag.to_s, @__node)
          @__node.root = node
        end
        node.instance_variable_set(:@__handler, __root_handler)
        @root = __root_handler.from_xml_element(node)
        if __root_handler.namespace_prefix
          node.namespace = node.namespace_scopes.find do |n|
            n.prefix == __root_handler.namespace_prefix
          end
        end
      end

      def method_missing(name, *args, &block)
        return super unless key?(name)
        return root unless name.to_s.end_with?('=')
        self.root = args.first
      end

      #
      # Is the current object empty?
      #
      # @return [Boolean]
      #
      def __empty?
        return false unless super
        __empty(root)
      end

      #
      # Get root object
      #
      # @return [XMLable::Mixins::Object]
      #
      def root
        __set_root(nil) unless instance_variable_defined?(:@root)
        @root
      end

      #
      # Get unwraped root object's value
      #
      # @return [Object]
      #
      def root!
        root.__object
      end

      #
      # Initialize root object with params
      #
      # @param [XMLable::Handlers::Root, XMLable::Handlers::RootNone] h root's handler
      # @param [Object] value
      #
      def __root_object_initialize(h, value)
        return self.root = value unless value.is_a?(Hash)
        value.each do |key, val|
          root[key].__initialize_with(val)
        end
      end

      #
      # Set root object content
      #
      # @param [Object] val
      #
      def root=(val)
        @root.__overwrite_content(val)
      end

      #
      # Does this object has root object with given key?
      #
      # @return [Boolean]
      #
      def key?(key)
        names = ['root', __root_handler.method_name]
        return __root_handler if names.include?(key.to_s)
        super
      end

      #
      # Get root object by key
      #
      # @param [String] key
      #
      def [](key)
        root if key?(key)
      end

      #
      # Set root object value
      #
      # @param [String] key
      # @param [Object] val
      #
      def []=(key, val)
        self.root = val if key?(key)
      end

      #
      # Cureent root object's handler
      #
      # @return [XMLable::Handlers::Root, XMLable::Handlers::RootNone]
      #
      def __root_handler
        self.class.__root_handler
      end

      module ClassMethods
        #
        # Define root handler
        #
        # @see XMLable::Handler::Base#build
        #
        def root(*args, &block)
          @__root_handler = Handlers::Root.build(*args, &block)
          __define_root(@__root_handler)
        end

        #
        # Define root object methods
        #
        # @param [XMLable::Handlers::Root] h root's handler
        #
        def __define_root(h)
          return if h.method_name == 'root'
          define_method(h.method_name) { root }
          define_method("#{h.method_name}=") { |val| self.root = val }
          define_method("#{h.method_name}!") { root! }
          define_method("__initialize_#{h.method_name}") { |val| __initialize_root(val) }
        end

        #
        # Root object's handler
        #
        # @return [XMLable::Handlers::Root, XMLable::Handlers::RootNone]
        #
        def __root_handler
          @__root_handler ||=
            __nested(:@__root_handler) || Handlers::RootNone.build(:root)
        end
      end
    end
  end
end
