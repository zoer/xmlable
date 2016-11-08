module XMLable
  module Handlers
    #
    # Base contains base handlers logic
    #
    class Base
      # @return [Object]
      attr_reader :type

      # @return [#call] returns block with additional settings
      attr_reader :block

      #
      # @param [String, Symbol] name element/attribute name
      # @param [Hash] opts adtional handler options
      # @option opts [Object] :tag element/attribute tag name
      # @option opts [Object] :type element/attribute class object
      # @option opts [Object] :container elements container
      #
      def initialize(name, opts = {}, &block)
        @name = name.to_s
        @type = opts.delete(:type) || String
        @block = block
      end

      #
      # Type class for the handler element
      #
      # @return [#new] returns class to store elements and attributes
      #
      def type_class
        klass = Builder.proxy_for(@type)
        wrapped_type? ? inject_wraped(klass) : klass
      end

      #
      # Proxy object which holds element data
      #
      # @return [#new]
      #
      def proxy
        raise NotImplementedError
      end

      #
      # Inject type class with addtional logic
      #
      # @param [Class] klass
      #
      # @return [Class]
      #
      def inject_wraped(klass)
      end

      def wrapped_type?
        Builder.wrapped_type?(type)
      end

      def options?
        !options.nil?
      end

      def options
        proxy.__options
      end

      #
      # Handler's element method name
      #
      # @return [String]
      #
      def method_name
        @name
      end

      #
      # Does the handler have additional settins
      #
      # @return [Boolean]
      #
      def block_settings?
        @block != nil
      end

      #
      # Factory to build a handler
      #
      # @return [XMLable::Handlers::Base]
      #
      def self.build(*args, &block)
        name = args.shift.to_s
        opts = args.last.is_a?(Hash) ? args.pop : {}
        opts[:type] = args.shift if args.size > 0
        opts[:container] = args.shift if args.size > 0

        # standalone
        opts[:tag] = opts[:type].__tag if opts[:type].respond_to?(:__tag)

        new(name, opts, &block)
      end
    end
  end
end
