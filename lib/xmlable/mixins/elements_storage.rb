module XMLable
  module Mixins
    #
    # ElementsStorage module contains the logic to store XML elements
    #
    module ElementsStorage
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Set element from XML Node
      #
      # @param [Symbol] name tag name
      # @param [Nokogiri::XML::Element, nil] el
      #
      # @api private
      #
      def __set_element(el, opts = {})
        unless el.is_a?(Nokogiri::XML::Element)
          el = Nokogiri::XML::Element.new(opts[:tag], @__node)
          @__node << el
          if opts[:namespace]
            el.namespace = el.namespace_scopes.find { |n| n.prefix == opts[:namespace] }
          end
        end
        h = __elements_handlers.for_xml_object(el)
        el.instance_variable_set(:@__handler, h)
        __initialize_elements_container(h) << h.from_xml_element(el)
      end

      #
      # Initialize elements container
      #
      # @param [XMLable::Handlers::Element, XMLable::Handlers::Elements, XMLable::Handlers::ElementNone] h
      #
      # @api private
      #
      # @return [XMLable::Mixins::Container]
      #
      def __initialize_elements_container(h)
        __elements[h.key] ||= h.container_for_xml_element(__node)
      end

      #
      # Elements which current object holds
      #
      # @api private
      #
      # @return [Hash(String => Array<XMLable::Mixins::Object>)]
      #
      def __elements
        @__elements ||= {}
      end

      #
      # Is this object empty?
      #
      # @api private
      #
      # @return [Boolean]
      #
      def __empty?
        return false unless super
        __elements.values.all?(&:__empty?)
      end

      def method_missing(name, *args, &blocks)
        h = __has_element_handler?(name)
        return super unless h

        if name.to_s.end_with?('=')
          __element_object_set(h, args.first)
        else
          __element_object_get(h)
        end
      end

      #
      # Elements handlers storage
      #
      # @api private
      #
      # @return [XMLable::Handlers::Storage]
      #
      def __elements_handlers
        @__elements_handler ||= self.class.__elements_handlers.clone
      end

      #
      # Does this object contain element with given key?
      #
      # @return [XMLable::Mixins::Object, false]
      #
      def key?(key)
        super || __has_element_handler?(key)
      end

      #
      # Get element object by its key
      #
      # @param [String] key element key
      #
      # @return [XMLable::Mixins::Object, nil]
      #
      def [](key)
        h = __has_element_handler?(key)
        h ? __element_object_get(h) : super
      end

      #
      # Set element value
      #
      # @param [String] key element key
      # @param [Object] val new value
      #
      # @return [XMLable::Mixins::Object, nil]
      #
      def []=(key, val)
        h = __has_element_handler?(key)
        h ? __element_object_set(h, val) : super
      end

      #
      # Find element handler by its key
      #
      # @param [Symbol, String] key
      #
      # @api private
      #
      # @return [XMLable::Handlers::Element, XMLable::Handlers::ElementNone, nil]
      #
      def __has_element_handler?(key)
        key = key.to_s.gsub(/[=!]$/, '')
        __elements_handlers.storage.find { |h| h.method_name == key }
      end

      #
      # Get element object
      #
      # @param [XMLable::Handlers::Element, XMLable::Handlers::Elements, XMLable::Handlers::ElementNone] h
      #
      # @api private
      #
      # @return [XMLable::Mixins::Object]
      #
      def __element_object_get(h)
        unless __elements.key?(h.key)
          if h.single?
            __set_element(nil, tag: h.tag, namespace: h.namespace_prefix)
          else
            __initialize_elements_container(h)
          end
        end
        ret = __elements[h.key]
        h.single? ? ret.first : ret
      end

      #
      # Set element object value
      #
      # @param [XMLable::Handlers::Element, XMLable::Handlers::Elements, XMLable::Handlers::ElementNone] h
      # @param [Object] val
      #
      # @api private
      #
      # @return [XMLable::Mixins::Object]
      #
      def __element_object_set(h, val)
        __element_object_get(h).__overwrite_content(val)
      end

      #
      # Set element object value
      #
      # @param [XMLable::Handlers::Element, XMLable::Handlers::Elements, XMLable::Handlers::ElementNone] h
      # @param [Object] val
      #
      # @api private
      #
      def __element_object_initialize(h, val)
        obj = __element_object_get(h)

        val = { '__content' => val } unless val.respond_to?(:each)
        if h.single?
          obj.__initialize_with(val)
        else
          val.map { |v| obj.new(v) }
        end
      end

      module ClassMethods

        #
        # Elements handlers storage
        #
        # @api private
        #
        # @return [XMLable::Handlers::Storage]
        #
        def __elements_handlers
          @__elements_handlers ||=
            __nested(:@__elements_handlers) || Handlers::Storage.new(default: Handlers::ElementNone)
        end

        %i[element elements].each do |m|
          define_method m do |*args, &block|
            opts = args.last.is_a?(Hash) ? args.pop : {}
            if __default_namespace && !opts.key?(:namespace)
              opts[:namespace] = __default_namespace
            end
            h = XMLable::Handlers.const_get(__method__.to_s.capitalize).build(*args, opts, &block)
            __elements_handlers << h
          end
        end
      end
    end
  end
end
