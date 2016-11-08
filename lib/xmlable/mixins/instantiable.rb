module XMLable
  module Mixins
    #
    # Instantiable module contains the logic to initialize the new elements
    #
    module Instantiable
      #
      # @param [Object] items initial params
      # @param [Nokogiri::XML::Node] node
      # @param [XMLable::Handlers::Base] handler
      #
      def initialize(items = nil, node = nil, handler = nil)
        super(node, handler)
        __initialize_with(items) if items
      end

      #
      # Initialize object with given value
      #
      # @param [Object] value
      #
      def __initialize_with(value)
        if value.is_a?(Hash)
          value.each do |key, val|
            if respond_to?(:__overwrite_content) && __content_methods.include?(key.to_s)
              next __overwrite_content(val)
            end

            h = key?(key)
            case h
            when Handlers::Attribute then __attribute_object_initialize(h, val)
            when Handlers::Root then __root_object_initialize(h, val)
            when Handlers::Element then __element_object_initialize(h, val)
            else raise h.inspect
            end
          end
        else
          case __handler
          when Handlers::Attribute then __overwrite_value(value)
          when Handlers::Element then __overwrite_content(value)
          else raise h.inspect
          end
        end
      end
    end
  end
end
