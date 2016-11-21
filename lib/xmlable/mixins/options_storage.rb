module XMLable
  module Mixins
    #
    # OptionsStorage modules contains method to manage with addtional options
    #
    module OptionsStorage
      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      module ClassMethods
        #
        # Set the export options
        #
        def on_export(*args)
          args.each { |opt| __options.opt_set(opt, true) }
        end

        #
        # Set the before export options
        #
        def before_export(&block)
          __options.opt_set(:before_export, block) if block_given?
        end

        #
        # Get the options storage
        #
        # @api private
        #
        # @return [XMLable::Options::Strage]
        #
        def __options
          @__options ||= __nested(:@__options) || Options::Storage.new
        end
      end
    end
  end
end
