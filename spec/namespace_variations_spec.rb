require 'spec_helper'

RSpec.describe 'namespace variations' do
  let(:doc) { klass.from_xml(xml) }
  let(:root) { doc.root }

  describe 'namespace inheritance' do
    let(:klass) do
      Class.new do
        include XMLable::Document

        nokogiri_export :no_declaration, :format

        root :student, namespace: 'd' do
          namespace nil, 'http://example.com'
          namespace :d, 'http://foo.com/student'

          attribute :id, :int

          element :name do
            attribute :position, :int
          end

          element :info, namespace: nil do
            element :city do
              attribute :number, Integer
            end
          end
        end
      end
    end
    let(:xml) do
      <<-XML.strip_heredoc.strip
        <d:student xmlns="http://example.com" xmlns:d="http://foo.com/student" d:id="11">
          <d:name d:position="2">Jeff Smith</d:name>
          <info>
            <city number="7">Beijing</city>
          </info>
        </d:student>
      XML
    end

    it 'should inherit default namespace' do
      expect(root).to has_namespace(:d)
      expect(root.id).to has_namespace(:d).and be_proxied 11
      expect(root.name).to has_namespace(:d).and be_proxied 'Jeff Smith'
      expect(root.name.position).to has_namespace(:d).and be_proxied 2
      expect(root.info).to has_default_namespace
      expect(root.info.city).to has_default_namespace.and be_proxied 'Beijing'
      expect(root.info.city.number).to has_default_namespace.and be_proxied 7
    end

    it 'should export' do
      expect(doc.to_xml).to eq xml
    end

    it 're-initialize with json' do
      d = klass.new(doc.to_h)
      expect(d.to_xml).to eq xml
    end
  end

  describe "when document has undesribed namespace" do
    let(:xml) do
      <<-XML.strip_heredoc.strip
        <cont:contact approved="false" test:approved="true">
           <cont:name>Tanmay Patil</cont:name>
           <cont:company>TutorialsPoint</cont:company>
           <cont:id>8</cont:id>
        </cont:contact>
      XML
    end

    let(:klass) do
      Class.new do
        include XMLable::Document

        nokogiri_export :no_declaration

        root :contact, tag: 'cont:contact' do
          attribute :approved1, :bool, tag: 'test:approved'
          attribute :approved2, :bool, tag: 'approved'

          element :name, tag: 'cont:name'
          element :company, tag: 'cont:company'
          element :id, :int, tag: 'cont:id'
        end
      end
    end

    it 'should work' do
      expect(root).to eq doc.contact
      expect(root.approved1).to has_default_namespace.and be_proxied true
      expect(root.approved2).to has_default_namespace.and be_proxied false
      expect(root.name).to has_default_namespace.and be_proxied 'Tanmay Patil'
      expect(root.company).to has_default_namespace.and be_proxied 'TutorialsPoint'
      expect(root.id).to has_default_namespace.and be_proxied 8
    end

    it 'should export' do
      expect(doc.to_xml).to eq xml
    end
  end
end
