module XMLable
  module Handlers
    module Mixins
      #
      # Namespace contains
      #
      module Namespace
        #
        # @see XMLable::Handlers::Base#initialize
        #
        def initialize(*args, &block)
          if args.last.is_a?(Hash)
            @namespace = args.last.delete(:namespace)
            @namespace = @namespace.to_s if @namespace
          end
          super
        end

        #
        # Get handler object namespace
        #
        # @return [String, nil]
        #
        def namespace_prefix
          @namespace if @namespace
        end

        #
        # Get handler combined key.
        #   It adds namespace to key if it exists.
        #
        # @return [String, nil]
        #
        def key
          [@namespace, @tag].compact.map(&:to_s).join(":")
        end
      end
    end
  end
end
