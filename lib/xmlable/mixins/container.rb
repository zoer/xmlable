module XMLable
  module Mixins
    #
    # Container module contains the logic for the XML objects groups
    #
    module Container
      # @return [XMLable::Handlers::Elements]
      attr_reader :__handler

      #
      # Create new element
      #
      # @param [Object] args element initial params
      #
      # @return [XMLable::Mixins::Object] returns created element
      #
      def new(args = nil)
        xml = Nokogiri::XML::Element.new(@__handler.tag.to_s, @__parent_node)
        el = @__handler.from_xml_element(xml)
        el.__initialize_with(args) if args
        @__parent_node << xml
        self << el
        el
      end

      #
      # Set current object handler
      #
      # @param [XMLable::Handlers::Elements] handler
      #
      # @api private
      #
      def __set_handler(handler)
        @__handler = handler
      end

      #
      # Parent XML node
      #
      # @api private
      #
      # @param [Nokogiri::XML::Node]
      #
      def __set_parent_node(node)
        @__parent_node = node
      end

      #
      # Initialize container with params
      #
      # @api private
      #
      # @param [Array<Object>] val
      #
      def __initialize_with(val)
        val.each { |v| new(v) }
      end

      #
      # Does this container contain only empty objects?
      #
      # @api private
      #
      # @return [Boolean]
      #
      def __empty?
        all?(&:__empty?)
      end
    end
  end
end
