module XMLable
  module Options
    #
    # NokogiriExport class contains Nokogiri's export settings
    #
    # @see http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Node/SaveOptions
    #
    class NokogiriExport < Hash
      #
      # Nokogiri's save_with options
      #
      # @return [Nokogiri::XML::Node::SaveOptions.new]
      #
      def save_with
        self[:save_with] ||= Nokogiri::XML::Node::SaveOptions.new
      end
    end
  end
end
