module XMLable
  module Mixins
    #
    # Castable module contains the logic that helps to cast values from
    #   different forms to XML/JSON and back.
    #
    module Castable
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Cast object from XML value
      #
      # @param [String] val
      #
      # @api private
      #
      # @return [Object]
      #
      def __cast(val)
        val
      end

      #
      # Export value to XML/JSON
      #
      # @param [Object] val
      #
      # @api private
      #
      # @return [Object]
      #
      def __export(val)
        val.to_s
      end

      #
      # Export value to XML
      #
      # @param [Object] val
      #
      # @api private
      #
      # @return [String]
      #
      def __export_to_xml(val)
        __export(val).to_s
      end

      #
      # Export value to JSON
      #
      # @param [Object] val
      #
      # @api private
      #
      # @return [Object]
      #
      def __export_to_json(val)
        __export(val).to_s
      end

      #
      # Is this object empty?
      #
      # @api private
      #
      # @return [Boolean]
      #
      def __empty(val)
        val.respond_to?(:empty?) && val.empty? ||
          val.is_a?(String) && val == '' ||
          val.nil?
      end

      module ClassMethods
        # @return [Array<Symbol>] retuns list of the setup methods
        CAST_METHODS = %i[cast export export_to_json export_to_xml empty]

        #
        # Override method missing to get the setup methods be available
        #
        # @see XMLable::Mixins::Castable::ClassMethods::CAST_METHODS
        #
        def method_missing(name, *args, &block)
          return super unless CAST_METHODS.include?(name)
          define_method("__#{name}", &block) if block_given?
        end
      end
    end
  end
end
