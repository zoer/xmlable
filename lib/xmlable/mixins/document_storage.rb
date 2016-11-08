module XMLable
  module Mixins
    #
    # DocumentStorage module contains the logic to work with XML document
    #
    module DocumentStorage
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # @param [Hash] args document initial params
      # @param [Nokogiri::XML::Document] doc XML document
      # @param [XMLable::Handlers::Document] handler document's handler
      #
      def initialize(args = {}, doc = nil, handler = nil)
        doc ||= Nokogiri::XML::Document.new
        handler ||= Handlers::Document.new(self.class)
        super
      end

      #
      # Get XML document version
      #
      # @return [String, nil]
      #
      def version
        __node.version
      end

      #
      # Get XML document encoding
      #
      # @return [String, nil]
      #
      def encoding
        __node.encoding
      end

      #
      # Get document's handler
      #
      # @api private
      #
      # @return [XMLable::Handlers::Document]
      #
      def __document_handler
        self.class.__document_handler
      end

      module ClassMethods
        #
        # Define document params
        #
        # @param [Hash] opts
        #
        def document(opts = {})
          opt(opts) if opts.size > 0
        end

        #
        # Set the Nokogiri's parsing params
        #
        def nokogiri_parse(*args)
          args.each do |opt|
            __nokogiri_parse_options.send(opt) if __nokogiri_parse_options.respond_to?(opt)
          end
        end

        #
        # Set the Nokogiri's export params
        #
        def nokogiri_export(*args)
          __nokogiri_export_options.tap do |opts|
            opts.merge!(args.pop) if args.last.is_a?(Hash)
            args.each { |opt| opts.save_with.send(opt) if opts.save_with.respond_to?(opt) }
          end
        end

        #
        # Nokogiri's options for parsing
        #
        # @api private
        #
        # @return [Nokogiri::XML::ParseOptions]
        #
        def __nokogiri_parse_options
          @__nokogiri_parse_options ||= Nokogiri::XML::ParseOptions.new.recover
        end

        #
        # Nokogiri's options for exporting
        #
        # @api private
        #
        # @return [Nokogiri::XML::ParseOptions]
        #
        def __nokogiri_export_options
          @__nokogiri_export_options ||= Options::NokogiriExport.new
        end

        #
        # Get document's handler
        #
        # @api private
        #
        # @return [XMLable::Handlers::Document]
        #
        def __document_handler
          @__document_handler ||= Handlers::Document.new(self)
        end

        #
        # Initialize document from XML
        #
        # @param [Nokogiri::XML::Document, String] xml
        # @param [Hash] _opts
        #
        # @return [XMLable::Document]
        #
        def from_xml(xml, _opts = {})
          xml = '' unless xml
          if xml.is_a?(String)
            doc = Nokogiri::XML(xml) do |config|
              config.options  = __nokogiri_parse_options.to_i
            end
          elsif xml.is?(Nokogiri::XML::Document)
            doc = xml
          else raise "Don't know how to parse '#{xml.class}'"
          end
          __document_handler.from_xml_document(doc)
        end
      end
    end
  end
end
