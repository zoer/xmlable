module XMLable
  module Exports
    #
    # XMLExporter class exports the data into XML format
    #
    class XMLExporter < Base
      #
      # @see XMLable::Exports::Base#initialize
      #
      def initialize(*)
        super
        @node = @element.__node
        @document = @node.document? ? @node : @node.document
      end

      #
      # Export the data into XML format
      #
      # @return [String]
      #
      def export
        opts = node_nested_options(@element.__node)
        builder.tap { |b| export_node(@element.__node, opts.merge(xml: b)) }
      end

      private

      #
      # XML builder
      #
      # @return [Nokogiri::XML:::Builder]
      #
      def builder
        opts = {}
        opts[:encoding] = @document.encoding if @document.encoding
        ::Nokogiri::XML::Builder.new(opts)
      end

      #
      # Get element's attributes
      #
      # @param [Nokogiri::XML::Element] node XML element
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Hash{String => String}]
      #
      def node_attributes(node, opts)
        return {} unless node.respond_to?(:attributes)
        attrs = node.attributes.values.select do |att|
          next if opts.drop_undescribed_attributes? && !described?(att)
          next if opts.drop_empty_attributes? && empty?(att)
          true
        end
        attrs.each_with_object({}) do |a, hash|
          name = [a.name]
          name.unshift(a.namespace.prefix) if a.namespace && a.namespace.prefix
          hash[name.join(':')] = a.value
        end
      end

      #
      # Get node's namespaces
      #
      # @param [Nokogiri::XML::Node] node
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Hash{String => String}]
      #
      def node_namespaces(node, opts)
        return {} unless node.respond_to?(:namespace_definitions)

        node.namespace_definitions.each_with_object({}) do |n, obj|
          name = ["xmlns", n.prefix].compact.join(":")
          obj[name] = n.href
        end
      end

      #
      # Export XML document
      #
      # @param [Nokogiri::XML::Document] doc
      # @param [XMLable::Options::Storage] opts
      #
      def export_document(doc, opts)
        export_node(doc.root, opts)
      end

      #
      # Export XML element
      #
      # @param [Nokogiri::XML::Element] node
      # @param [XMLable::Options::Storage] opts
      #
      def export_element(node, opts)
        opts = node_merged_opts(node, opts)
        ns = node.namespace
        if ns && !node_ns_definition(node, ns.prefix)
          opts[:xml] = opts[:xml][ns.prefix] if ns.prefix
        end
        opts[:xml].send("#{node.name}_", element_args(node, opts)) do |xml|
          if ns && node_ns_definition(node, ns)
            xml.parent.namespace = node_ns_definition(xml.parent, ns.prefix)
          end
          if !opts.drop_empty_elements? || !empty?(node)
            export_node_children(node, opts.merge(xml: xml))
          end
        end
      end

      #
      # Get XML element's attributes and namespace definitions
      #
      # @param [Nokogiri::XML::Element] node
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Hash{String => String}]
      #
      def element_args(node, opts)
        node_namespaces(node, opts).merge(node_attributes(node, opts))
      end

      #
      # Get element's namespace definition
      #
      # @param [Nokogiri::XML::Element] node
      # @param [Nokogiri::XML::Namespace, String] ns
      #
      # @return [Nokogiri::XML::Namespace, nil] returns namespace if it's found,
      #   otherwise +nil+
      #
      def node_ns_definition(node, ns)
        prefix = ns.is_a?(Nokogiri::XML::Namespace) ? ns.prefix : ns
        node.namespace_definitions.find { |n| n.prefix == prefix }
      end

      #
      # Export nodes' children
      #
      # @param [Nokogiri::XML::Element] node
      # @param [XMLable::Options::Storage] opts
      #
      def export_node_children(node, opts)
        node.children.each do |child|
          next if child.is_a?(Nokogiri::XML::Attr)
          if child.is_a?(Nokogiri::XML::Element)
            next if opts.drop_empty_elements? && empty?(child)
            next if opts.drop_undescribed_elements? && !described?(child)
          end
          export_node(child, opts)
        end
      end

      #
      # Export XML text node
      #
      # @param [Nokogiri::XML::Text] node
      # @param [XMLable::Options::Storage] opts
      #
      def export_text(node, opts)
        opts[:xml].text(node.text)
      end

      #
      # Export XML node
      #
      # @param [Nokogiri::XML::Node] node
      # @param [XMLable::Options::Storage] opts
      #
      def export_node(node, opts)
        case node
        when Nokogiri::XML::Document then export_document(node, opts)
        when Nokogiri::XML::Element  then export_element(node, opts)
        when Nokogiri::XML::Text     then export_text(node, opts)
        else fail "Don't know how to export node: #{node}"
        end
      end
    end
  end
end
