module XMLable
  module Exports
    #
    # Base class contains the base export logic
    #
    class Base
      #
      # Initialize
      #
      # @param [XMLable::Mixins::Object] element
      # @param [Hash] opts
      #
      def initialize(element, opts = {})
        @element = element
        @opts = opts
      end

      #
      # Is this object empty?
      #
      # @param [Nokogiri::XML::Node] node
      #
      # @return [Boolean]
      #
      def empty?(node)
        node.instance_variable_get(:@__element).__empty?
      end

      #
      # Is the object described by user?
      #
      # @param [Nokogiri::XML::Node] node
      #
      # @return [Boolean]
      #
      def described?(node)
        node.instance_variable_get(:@__handler).described?
      end

      #
      # Get node's nested options
      #
      # @param [Nokogiri::XML::Node] node
      #
      # @return [XMLable::Options::Storage]
      #
      def node_nested_options(node)
        return Options::Storage.new unless node
        parent = node.respond_to?(:parent) ? node.parent : nil
        node_nested_options(parent).merge_opts(node_options(node))
      end

      #
      # Get node's options
      #
      # @param [Nokogiri::XML::Node] node
      #
      # @return [XMLable::Options::Storage]
      #
      def node_options(node)
        h = node.instance_variable_get(:@__handler)
        h && h.options? ? h.options : Options::Storage.new
      end

      #
      # Merge node's options
      #
      # @param [Nokogiri::XML::Node] node
      # @param [XMLable::Options::Storage] opts
      #
      # @return [XMLable::Options::Storage]
      #
      def node_merged_opts(node, opts = Options::Storage.new)
        opts.merge_opts(node_options(node))
      end
    end
  end
end
