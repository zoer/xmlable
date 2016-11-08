module XMLable
  module Mixins
    #
    # BareValue contains logic to get the bare value.
    #   All XML object such as Integer, Date, String, etc are wrapped with the
    #   proxy classes. This module helps to unwrap the real value.
    #
    module BareValue
      def method_missing(name, *args, &block)
        return super unless name.to_s =~ /!$/
        return super unless key?(name)
        name = name.to_s.gsub(/!$/,'').to_sym
        __extract_bare_value(super)
      end

      #
      # Get object value
      #   It unwraps the object value if object key ends with '!' symbol.
      #
      # @return [XMLable::Mixins::Object, Object, nil]
      #
      def [](key)
        return super unless key.to_s =~ /!$/
        __extract_bare_value(super)
      end

      #
      # Unwrap objects
      #
      # @param [XMLable::Mixins::Object, Array<XMLable::Mixins::Object>] obj
      #
      # @api private
      #
      # @return [Object, Array<Object>]
      #
      def __extract_bare_value(obj)
        obj.respond_to?(:map) ?  obj.map(&:__object) : obj.__object
      end
    end
  end
end
