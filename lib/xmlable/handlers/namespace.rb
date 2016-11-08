module XMLable
  module Handlers
    #
    # Namespace handles XML namespace objects
    #
    class Namespace
      # @return [Symbol, nil] returns namespace's prefix
      attr_reader :prefix
      # @return [Symbol] returns namespace's URI
      attr_reader :prefix, :href

      #
      # @param [Symbol, String, nil] prefix_or_href namespace's URI or prefix
      # @param [String] href namespace's URI
      #
      def initialize(prefix_or_href = nil, href = nil, _opts = {})
        if prefix.to_s =~ URI.regexp
          @href = prefix_or_href
        else
          @prefix = prefix_or_href
          @href = href
        end
      end
    end
  end
end
