module XMLable
  module Mixins
    #
    # ValueStorage modules contains the logic to manage XML attributes values
    #
    module ValueStorage
      #
      # Set XML attribute value
      #
      # @param [Nokogiri::XML::Attr] node XML attribute node
      #
      # @api private
      #
      def __set_value(node)
        self.__value = __cast(node.content)
      end

      #
      # Set value
      #
      # @api private
      #
      # @param [Object] val
      #
      def __value=(val)
        @__value = val
      end

      #
      # Overwrite XML attribute's value
      #
      # @api private
      #
      # @param [Object] val
      #
      def __overwrite_value(val)
        @__node.content = __export_to_xml(val)
        self.__value = val
      end

      #
      # Get unwraped attribute object's value
      #
      # @api private
      #
      # @return [Object]
      #
      def __object
        __value
      end

      #
      #
      # Get attribute value
      #
      # @api private
      #
      # @return [Object]
      #
      def __value
        @__value
      end

      #
      # Is this element empty?
      #
      # @api private
      #
      # @return [Boolean]
      #
      def __empty?
        return false unless super
        __empty(__value)
      end

      #
      # @return [String]
      #
      def to_s
        __value.to_s
      end
    end
  end
end
