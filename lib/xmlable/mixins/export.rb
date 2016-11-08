module XMLable
  module Mixins
    #
    # Export modules contains method to export
    #
    module Export
      #
      # Export to XML
      #
      # @param [Hash] opts
      #
      # @return [String] returns exported XML
      #
      def to_xml(opts = {})
        exporter = Exports::XMLExporter.new(self, opts)
        opts = self.class.__nokogiri_export_options.merge(opts)
        exporter.export.to_xml(opts).strip
      end

      #
      # Export to JSON
      #
      # @param [Hash] opts
      # @option opts [Boolean] :pretty enable pretty print
      #
      # @return [String] returns exported JSON
      #
      def to_json(opts = {})
        ret = to_h(opts)
        opts[:pretty] ? JSON.pretty_generate(ret) : ret.to_json
      end

      #
      # Export to hash
      #
      # @param [Hash] opts
      #
      # @return [Hash]
      #
      def to_h(opts = {})
        Exports::JSONExporter.new(self, opts).export
      end
    end
  end
end
