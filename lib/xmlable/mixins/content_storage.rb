module XMLable
  module Mixins
    #
    # ContentStorage module contains the logic that helps to store XML element
    #   content.
    #
    module ContentStorage
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Set XML element content
      #
      # @param [Nokogiri::XML::Element] node
      #
      # @api private
      #
      def __set_content(node)
        val = node.children.select(&:text?).map(&:content).join('').strip
        @__content = __cast(val)
      end

      #
      # Override XML node content
      #
      # @param [Object] value
      #
      # @api private
      #
      def __overwrite_content(val)
        val = __cast(val)
        @__node.content = __export_to_xml(val)
        @__content = val
      end

      #
      # Get content value
      #
      # @api private
      #
      # @return [Object]
      #
      def __object
        __content
      end

      #
      # Get content value
      #
      # @api private
      #
      # @return [Object]
      #
      def __content
        @__content
      end

      #
      # Set content value
      #
      # @param [Object] value
      #
      # @api private
      #
      # @return [Object]
      #
      def __content=(val)
        __overwrite_content(val)
      end

      #
      # Is this element?
      #
      # @api private
      #
      # @return [Boolean]
      #
      def __empty?
        return false unless super
        __empty(__content)
      end

      #
      # @return [String]
      #
      def to_s
        __content.to_s
      end

      #
      # Get content alias method
      #
      # @api private
      #
      # @return [String, nil]
      #
      def __content_method
        self.class.__content_method
      end

      #
      # Contents methods
      #
      # @api private
      #
      # @return [Array<String>]
      #
      def __content_methods
        ret = ['__content']
        ret << __content_method.to_s if __content_method
        ret
      end

      module ClassMethods
        #
        # Define content method
        #   If given +false+ name than content isn't available to this element.
        #
        # @param [String, Symbol, false]  name
        #
        def content(name)
          @__content_method = name.is_a?(String) ? name.to_sym : name
        end

        #
        # Get content method
        #
        # @return [String, nil, false]
        #
        def __content_method
          return @__content_method if instance_variable_defined?(:@__content_method)
          @__content_method = __nested(:@__content_method)
        end
      end
    end
  end
end
