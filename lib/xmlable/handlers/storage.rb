module XMLable
  module Handlers
    #
    # Storage stores handlers
    #
    class Storage
      # @return [Array<XMLable::Handlers::Base>]
      attr_reader :storage

      #
      # @param [Hash] opts additional options
      # @option opts [XMLable::Handlers::Base] :default default handler's class
      # @param [Array] storage initial handlers to store
      #
      def initialize(opts = {}, storage = [])
        @opts = opts
        @storage = storage
      end

      #
      # Find or create handler for the XML node
      #
      # @param [XML::Nokogiri::Node] node
      #
      # @return [XMLable::Handlers::Base]
      #
      def for_xml_object(node)
        tag = node.name.to_s
        namespace = node.namespace.prefix if node.namespace
        namespace = namespace.to_s if namespace
        handler_with_tag!(tag, namespace: namespace)
      end

      #
      # Append new handler to storage
      #
      # @note Described handler is always on top of the list
      #
      # @param [XMLable::Handler::Base] handler
      #
      def <<(handler)
        @storage << handler
        @storage = @storage.sort_by { |h| !h.described?.to_s }
      end

      #
      # Find handler with given tag
      #
      # @param [String] tag element tag name
      # @param [Hash] opts
      # @option opts [String, nil] :namespace element namespace
      #
      # @return [XMLable::Handlers::Base, nil] returns handler if it's found,
      #   otherwise return +nil+
      #
      def handler_with_tag(tag, opts = {})
        match = @storage.find { |h| h.tag == tag }
        return match if !match || !opts.key?(:namespace)
        return match if opts[:namespace] == false
        match.namespace_prefix == opts[:namespace] ? match : nil
      end

      #
      # Find handler with given tag or create a new one
      #
      # @param [String] tag element tag name
      # @param [Hash] opts
      # @option opts [String, nil] :namespace element namespace
      #
      # @return [XMLable::Handlers::Base]
      #
      def handler_with_tag!(tag, opts = {})
        match = handler_with_tag(tag, opts)
        return match if match
        default_handler.build(tag, opts).tap { |h| self << h }
      end

      #
      # Clone handlers storage
      #
      # @return [XMLable::Handers::Storage]
      #
      def clone
        self.class.new(@opts, storage.clone)
      end

      #
      # Default handler class
      #
      # @return [XMLable::Handlers::Base] returns null object handler
      #
      def default_handler
        @opts[:default]
      end

      #
      # @return [String]
      #
      def inspect
        "#<XMLable::Handlers::Storage #{@storage.map(&:key).join(', ')} >"
      end
    end
  end
end
