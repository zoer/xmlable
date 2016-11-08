module XMLable
  module Options
    #
    # Storage class stores handlers options
    #
    class Storage < Hash
      #
      # Initialize
      #
      # @param [Hash] hash initial params
      #
      def new(hash = {})
        opts_set(hash)
      end

      #
      # Set multiple options
      #
      # @param [Hash] hash
      #
      def opts_set(hash)
        hash.each { |key, value| opt_set(key, value) }
      end

      #
      # Set option
      #
      # @param [String, Symbol] key
      # @param [Object] value
      #
      # @return [XMLable::Options::Storage]
      #
      def opt_set(key, value)
        key = key.to_s
        value = false if key =~ /^no_/
        key = key.sub(/^no_/, '').to_sym
        method = "opt_set_#{key}"
        respond_to?(method) ? send(method, value) : opt_default_set(key, value)
        self
      end

      #
      # Set the drop empty objects
      #
      # @param [Boolean]
      #
      def opt_set_drop_empty(value)
        self[:drop_empty_attributes] = self[:drop_empty_elements] = value
      end

      #
      # Set the drop undescribed objects
      #
      # @param [Boolean]
      #
      def opt_set_drop_undescribed(value)
        self[:drop_undescribed_attributes] = self[:drop_undescribed_elements] = value
      end

      #
      # Default option setter
      #
      # @param [String, Symbol] key
      # @param [Object] value
      #
      def opt_default_set(key, value)
        self[key.to_sym] = value
      end

      %i[undescribed empty].each do |m|
        %i[attributes elements].each do |e|
          define_method("drop_#{m}_#{e}?") { fetch(:"drop_#{m}_#{e}", false) }
        end
      end

      #
      # Merge options
      #
      # @param [Hash, XMLable::Options::Storage] opts
      #
      # @return [XMLable::Options::Storage]
      #
      def merge_opts(other)
        merger = proc do |_, v1, v2|
          if [v1, v2].all? { |h| h.is_a?(Hash) }
            v1.merge(v2, &merger)
          elsif [v1, v2].all? { |h| h.is_a?(Array) }
            v1 + v2
          else
            v2
          end
        end
        merge(other, &merger)
      end
    end
  end
end
