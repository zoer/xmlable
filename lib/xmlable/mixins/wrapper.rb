module XMLable
  module Mixins
    #
    # Wrapper module contains methods to wrap the primitive classes
    #
    module Wrapper
      def method_missing(*args, &block)
        __object.send(*args, &block)
      end

      #
      # @return [String]
      #
      def to_s(*args)
        __object.to_s(*args)
      end

      #
      # Is wrapped class inherits from given class?
      #
      # @param [Class] klass
      #
      # @param [Boolean]
      #
      def is_a?(klass)
        __object.is_a?(klass)
      end

      #
      # @return [String]
      #
      def inspect
        "[Wrapper(#{__object.class})] #{__object.inspect}"
      end
    end
  end
end
