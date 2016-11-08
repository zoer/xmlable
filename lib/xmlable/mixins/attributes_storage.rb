module XMLable
  module Mixins
    #
    # AttributesStorage module contains the logic for object that able to
    #   store XML attributes
    #
    module AttributesStorage
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Set XML attribute
      #
      # @param [Nokogiri::XML::Attr, nil] att
      # @param [Hash] opts
      # @option opts [String] :tag attribute's name
      # @option opts [String] :namespace attribute's namespace
      #
      # @api private
      #
      def __set_attribute(att, opts = {})
        unless att
          @__node[opts[:tag]] = att
          att = @__node.attributes[opts[:tag]]
          if opts[:namespace]
            att.namespace = att.namespace_scopes.find { |n| n.prefix == opts[:namespace] }
          end
        end
        h = __attributes_handlers.for_xml_object(att)
        att.instance_variable_set(:@__handler, h)
        __attributes[h.key] = h.from_xml_attribute(att)
      end

      #
      # Attributes which current object holds
      #
      # @api private
      #
      # @return [Hash(String => Array<XMLable::Mixins::Object>)]
      #
      def __attributes
        @__attributes ||= {}
      end

      #
      # Is this object empty?
      #
      # @api private
      #
      # @return [Hash(String => Array<XMLable::Mixins::Object>)]
      #
      def __empty?
        return false unless super
        __attributes.values.all?(&:__empty?)
      end

      def method_missing(name, *args, &block)
        h = __has_attribute_handler?(name)
        return super unless h

        if name.to_s.end_with?('=')
          __attribute_object_set(h, args.first)
        else
          __attribute_object_get(h)
        end
      end

      #
      # Does this object contain attribute with given key?
      #
      # @return [XMLable::Mixins::Object, false]
      #
      def key?(key)
        super || __has_attribute_handler?(key)
      end

      #
      # Get attribute object by its key
      #
      # @param [String] key attribute key
      #
      # @return [XMLable::Mixins::Object, nil]
      #
      def [](key)
        h = __has_attribute_handler?(key)
        h ? __attribute_object_get(h) : super
      end

      #
      # Set attribute value
      #
      # @param [String] key attribute key
      # @param [Object] val new value
      #
      # @return [XMLable::Mixins::Object, nil]
      #
      def []=(key, val)
        h = __has_attribute_handler?(key)
        h ? __attribute_object_set(h, val) : super
      end

      #
      # Find attribute handler by its key
      #
      # @param [Symbol, String] key
      #
      # @api private
      #
      # @return [XMLable::Handlers::Attribute, XMLable::Handlers::AttributeNone, nil]
      #
      def __has_attribute_handler?(key)
        key = key.to_s.gsub(/[=!]$/, '')
        __attributes_handlers.storage.find { |h| h.method_name == key }
      end

      #
      # Get attribute object
      #
      # @param [XMLable::Handlers::Attribute, XMLable::Handlers::AttributeNone] h
      #
      # @api private
      #
      # @return [XMLable::Mixins::Object]
      #
      def __attribute_object_get(h)
        unless __attributes.key?(h.key)
          __set_attribute(nil, tag: h.tag, namespace: h.namespace_prefix)
        end
        __attributes[h.key]
      end

      #
      # Set attribute object value
      #
      # @param [XMLable::Handlers::Attribute, XMLable::Handlers::AttributeNone, nil] h
      # @param [Object] val new value
      #
      # @api private
      #
      def __attribute_object_set(h, val)
        __attribute_object_get(h).__overwrite_value(val)
      end

      #
      # Initialize attribute object with value
      #
      # @param [XMLable::Handlers::Attribute, XMLable::Handlers::AttributeNone, nil] h
      # @param [Object] val
      #
      # @api private
      #
      def __attribute_object_initialize(h, value)
        __attribute_object_get(h).__overwrite_value(value)
      end

      #
      # Attributes handlers storage
      #
      # @return [XMLable::Handlers::Storage]
      #
      def __attributes_handlers
        @__attributes_handler ||= self.class.__attributes_handlers.clone
      end

      module ClassMethods
        #
        # Attributes handlers storage
        #
        # @return [XMLable::Handlers::Storage]
        #
        def __attributes_handlers
          @__attributes_handlers ||=
            __nested(:@__attributes_handlers) || Handlers::Storage.new(default: Handlers::AttributeNone)
        end

        #
        # Describe object attribute
        #
        # @see XMLable::Handler::Base#build
        #
        # @return [XMLable::Handlers::Storage]
        #
        def attribute(*args, &block)
          opts = args.last.is_a?(Hash) ? args.pop : {}
          if __default_namespace && !opts.key?(:namespace)
            opts[:namespace] = __default_namespace
          end
          h = Handlers::Attribute.build(*args, opts, &block)
          __attributes_handlers << h
        end
      end
    end
  end
end
