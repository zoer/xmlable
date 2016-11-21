module XMLable
  module Mixins
    #
    # NamespaceDefinitionsStorage module contains the logic to manage with XML
    #   namespaces definitions
    #
    module NamespaceDefinitionsStorage
      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      #
      # @see XMLable::Mixins::Object#initialize
      #
      def initialize(*)
        super
        __define_namespaces(__namespace_definitions)
      end

      #
      # Define XML namespaces
      #
      # @param [Array<XMLable::Handlers::Namespace>] handlers
      #
      # @api private
      #
      def __define_namespaces(handlers)
        handlers.each do |h|
          next if __node.namespace_scopes.find { |ns| ns.prefix == h.prefix }
          __node.add_namespace_definition(h.prefix ? h.prefix.to_s : nil, h.href)
        end
      end

      #
      # Set XML namespace
      #
      # @param [Nokogiri::XML::Namespace] ns
      #
      # @api private
      #
      def __set_namespace_definition(ns)
        __namespace_definitions << ns
      end

      #
      # Get namespace definition handlers
      #
      # @api private
      #
      # @return [XMLable::Handlers::Storage]
      #
      def __namespace_definitions
        @__namespace_definitions ||= self.class.__namespace_definitions.clone
      end

      module ClassMethods
        #
        # Define XML namespace
        #
        # @see XMLable::Handlers::Base#build
        #
        def namespace(*args)
          opts = args.last.is_a?(Hash) ? args.pop : {}
          default = opts.delete(:default) || true
          h = Handlers::Namespace.new(*args, opts)
          self.__default_namespace = h.prefix if default
          __namespace_definitions << h
        end

        #
        # Default namespace prefix
        #
        # @api private
        #
        # @return [Symbol, nil]
        #
        def __default_namespace
          @__default_namespace
        end

        #
        # Set default namespace prefix
        #
        # @api private
        #
        # @param [Symbol, nil]
        #
        def __default_namespace=(val)
          @__default_namespace = val
        end

        #
        # Get namespace definition handlers
        #
        # @api private
        #
        # @return [XMLable::Handlers::Storage]
        #
        def __namespace_definitions
          @__namespace_definitions ||= []
        end
      end
    end
  end
end
