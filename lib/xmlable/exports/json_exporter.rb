module XMLable
  module Exports
    #
    # JSONExporter class exports object into JSON format
    #
    class JSONExporter < Base
      #
      # Export into JSON format
      #
      # @return [Hash]
      #
      def export
        opts = node_nested_options(@element.__node)
        export_object(@element, opts)
      end

      #
      # Is object empty?
      #
      # @param [XMLable::Mixins::Object] el
      #
      # @return [Boolean]
      #
      def empty?(el)
        el.__empty?
      end

      #
      # Is object described by user?
      #
      # @param [XMLable::Handlers::Base, XMLable::Mixins::Object]
      #
      # @return [Boolean]
      #
      #
      def described?(obj)
        handler = obj.is_a?(XMLable::Handlers::Base) ? obj : obj.__handler
        handler.described?
      end

      #
      # Get object's key
      #
      # @param [XMLable::Handlers::Base, XMLable::Mixins::Object]
      #
      # @return [String]
      #
      def key(obj, opts)
        handler = obj.is_a?(XMLable::Handlers::Base) ? obj : obj.__handler
        handler.method_name
      end

      #
      # Get object's handlers
      #
      # @param [XMLable::Mixins::Object] el
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Array<XMLable::Handler::Base>]
      #
      def object_handlers(el, opts)
        handlers = []
        if el.respond_to?(:__attributes_handlers)
          el.__attributes_handlers.storage.each do |h|
            next if opts.drop_undescribed_attributes? && !described?(h)
            handlers << h
          end
        end
        if el.respond_to?(:__elements_handlers)
          el.__elements_handlers.storage.each do |h|
            next if opts.drop_undescribed_elements? && !described?(h)
            handlers << h
          end
        end
        handlers
      end

      #
      # Export group of elements
      #
      # @param [XMLable::Mixins::Container<XMLable::Mixins::Object>] els
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Array<Hash>]
      #
      def export_elements(els, opts)
        els.each_with_object([]) do |e, arr|
          next if opts.drop_empty_elements? && empty?(e)
          arr << export_object(e, opts)
        end
      end

      #
      # Export attribute object's value
      #
      # @param [XMLable::Mixins::Object] el
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Object]
      #
      def export_value(el, opts)
        el.__export_to_json(el.__object)
      end

      #
      # Export element object's content
      #
      # @param [XMLable::Mixins::Object] el
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Object]
      #
      def export_content(el, opts)
        el.__export_to_json(el.__object)
      end

      #
      # Get object key
      #
      # @param [XMLable::Handlers::Base, XMLable::Mixins::Object]
      #
      def key(obj, opts)
        handler = obj.is_a?(XMLable::Handlers::Base) ? obj : obj.__handler
        handler.method_name
      end

      #
      # Export element object
      #
      # @param [XMLable::Mixins::Object] el
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Object]
      #
      def export_element(el, opts)
        opts = node_merged_opts(el.__node, opts)
        handlers = object_handlers(el, opts)
        content = export_content(el, opts)
        return content if handlers.size == 0

        ret = export_element_children(el, opts)

        if !content.to_s.empty? || !opts.drop_empty_elements?
          content_method = el.__content_method
          if (content_method || !opts.drop_undescribed_elements?) && content_method != false
            ret["#{content_method || '__content'}"] = content unless content.to_s.empty?
          end
        end

        ret
      end

      #
      # Export element's nested objects
      #
      # @param [XMLable::Mixins::Object] el
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Hash]
      #
      def export_element_children(el, opts)
        object_handlers(el, opts).each_with_object({}) do |h, memo|
          obj = el[h.method_name]
          if h.is_a?(Handlers::Element)
            next if opts.drop_empty_elements? && empty?(obj)
          elsif h.is_a?(Handlers::Attribute)
            next if opts.drop_empty_attributes? && empty?(obj)
          end
          memo[key(h, opts)] = export_object(obj, opts)
        end
      end

      #
      # Export root object
      #
      # @param [XMLable::Mixins::Object] el
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Hash{String => Object}]
      #
      def export_root(el, opts)
        tag = described?(el.root) ? key(el.root, opts) : el.__node.root.name
        if !opts.drop_empty_elements? || !empty?(el.root)
          value = export_object(el.root, opts)
        end
        { tag => value }
      end

      #
      # Export object
      #
      # @param [XMLable::Mixins::Object, XMLable::Mixins::Container] obj
      # @param [XMLable::Options::Storage] opts
      #
      # @return [Object]
      #
      def export_object(obj, opts)
        case obj
        when Mixins::Container       then export_elements(obj, opts)
        when Mixins::ElementsStorage then export_element(obj, opts)
        when Mixins::RootStorage     then export_root(obj, opts)
        when Mixins::ValueStorage    then export_value(obj, opts)
        else fail("Don't know how to export #{obj.class.ancestors.inspect}.")
        end
      end
    end
  end
end
