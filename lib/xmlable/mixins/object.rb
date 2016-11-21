module XMLable
  module Mixins
    #
    # Base class contains base item's methods
    #
    module Object
      # @return [Nokogiri::XML::Node]
      attr_reader :__node
      # @return [XMLable::Handlers::Base]
      attr_reader :__handler

      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      #
      # Initialize
      #
      # @param [Nokogiri::XML::Node] node item's XML node
      # @param [XMLable::Handlers::Base] handler item's handler
      #
      def initialize(node, handler)
        @__node    = node
        @__handler = handler
        __inject_node(@__node, @__handler)
      end

      #
      # Is this object empty?
      #
      # @api private
      #
      # @return [Boolean]
      #
      def __empty?
        true
      end

      #
      # Does this object have a nested object with given key
      #
      # @return [Object, false]
      #
      def key?(*)
        false
      end

      #
      # Get nested object
      #
      def [](*)
      end

      #
      # get nested object value
      #
      def []=(*)
      end

      #
      # Inject XML node and handler with the curren object
      #
      # @param [Nokogiri::XML::Node] node item's XML node
      # @param [XMLable::Handlers::Base] handler item's handler
      #
      # @api private
      #
      def __inject_node(node, handler)
        node.instance_variable_set(:@__handler, handler)
        node.instance_variable_set(:@__element, self)
      end

      module ClassMethods
        #
        # Get inherited object value if it's set
        #
        # @param [String, Symbol] var varibale name
        #
        # @return [Object, nil]
        #
        def __nested(var)
          klass = superclass
          obj = nil
          loop do
            obj = klass.instance_variable_get(var)
            break if obj || !(klass = klass.superclass)
          end
          obj ? obj.clone : nil
        end
      end
    end
  end
end
