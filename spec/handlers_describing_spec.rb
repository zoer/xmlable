require 'spec_helper'

RSpec.describe 'Handlers describing' do
  let(:klass) do
    Class.new do
      include XMLable::Document

      root :bill do
        attribute :date, Date, tag: 'when'

        element :paid, :bool

        elements :items do
          attribute :position, Integer
          element :cost, :float
        end
      end
    end
  end
  let(:params) { {} }
  let(:doc) { klass.new(params) }
  let(:root) { doc.root }

  shared_examples 'described handlers' do
    let(:rh) { doc.__root_handler }

    it 'should have descibed handlers' do
      expect(doc.root).to eq doc.bill
      expect(doc.root.__handler).to eq rh

      expect(rh.tag).to eq 'bill'
      expect(rh.key).to eq 'bill'
      expect(rh.method_name).to eq 'bill'
      expect(rh.namespace_prefix).to be_nil
      expect(rh.type).to eq String
      expect(rh.described?).to eq true
      expect(rh.single?).to eq true
      expect(rh).to be_a XMLable::Handlers::Element

      dh = root.date.__handler
      expect(dh.tag).to eq 'when'
      expect(dh.method_name).to eq 'date'
      expect(dh.key).to eq 'when'
      expect(dh.namespace_prefix).to be_nil
      expect(dh.type).to eq Date
      expect(dh.described?).to eq true
      expect(dh).to be_a XMLable::Handlers::Attribute

      ph = root.paid.__handler
      expect(ph.tag).to eq 'paid'
      expect(ph.method_name).to eq 'paid'
      expect(ph.key).to eq 'paid'
      expect(ph.namespace_prefix).to be_nil
      expect(ph.type).to eq :bool
      expect(ph.described?).to eq true
      expect(ph.single?).to eq true
      expect(ph).to be_a XMLable::Handlers::Element

      ih = root.items.__handler
      expect(ih.tag).to eq 'items'
      expect(ih.method_name).to eq 'items'
      expect(ih.key).to eq 'items'
      expect(ih.namespace_prefix).to be_nil
      expect(ih.type).to eq String
      expect(ih.described?).to eq true
      expect(ih.single?).to eq false
      expect(ih).to be_a XMLable::Handlers::Element

      root.items.new if root.items.size == 0
      expect(ih).to eq root.items.first.__handler

      ph = root.items.first.position.__handler
      expect(ph.tag).to eq 'position'
      expect(ph.method_name).to eq 'position'
      expect(ph.key).to eq 'position'
      expect(ph.namespace_prefix).to be_nil
      expect(ph.type).to eq Integer
      expect(ph.described?).to eq true
      expect(ph).to be_a XMLable::Handlers::Attribute

      ch = root.items.first.cost.__handler
      expect(ch.tag).to eq 'cost'
      expect(ch.method_name).to eq 'cost'
      expect(ch.key).to eq 'cost'
      expect(ch.namespace_prefix).to be_nil
      expect(ch.type).to eq :float
      expect(ch.described?).to eq true
      expect(ch).to be_a XMLable::Handlers::Element
    end
  end

  describe 'when initialized with empty params' do
    it_behaves_like 'described handlers'
  end

  describe 'when initialized with not empty' do
    let(:params) do
      {
        bill: {
          date: '2015-01-20',
          paid: false,
          items: [
            { position: 1, cost: 12.2 },
            { position: 2, cost: 83.8 }
          ]
        }
      }
    end

    it_behaves_like 'described handlers'
  end

  describe 'from xml' do
    let(:xml) do
      <<-XML.strip_heredoc
        <?xml version="1.0"?>
        <bill date="2015-01-20">
          <paid>true</paid>
          <item position="1">
            <cost>12.2</cost>
          </item>
          <item position="2">
            <cost>83.8</cost>
          </item>
        </bill>
      XML
    end
    let(:doc) { klass.from_xml(xml) }

    it_behaves_like 'described handlers'
  end

  describe 'when initialization params have undescribed values' do
    let(:params) do
      {
        bill: {
          paid: false,
          undescribed_value: 'foo'
        }
      }
    end

    it 'should raise an error' do
      expect { doc }.to raise_error NoMethodError
    end
  end

  describe 'when XML has undescribed elements' do
    let(:xml) do
      <<-XML.strip_heredoc
        <?xml version="1.0"?>
        <bill date="2015-01-20">
          <paid>true</paid>
          <undescribed att="foo11">
            <el>foo12</el>
          </undescribed>
          <undescribed att="foo21">
            <el>foo22</el>
          </undescribed>
        </bill>
      XML
    end
    let(:doc) { klass.from_xml(xml) }

    it_behaves_like 'described handlers'

    it 'should have undescribed handlers' do
      dh = root.undescribed.__handler
      expect(dh.tag).to eq 'undescribed'
      expect(dh.method_name).to eq 'undescribed'
      expect(dh.key).to eq 'undescribed'
      expect(dh.namespace_prefix).to be_nil
      expect(dh.type).to eq String
      expect(dh.described?).to eq false
      expect(dh).to be_a XMLable::Handlers::Element

      root.undescribed.each { |e| expect(e.__handler).to eq dh }

      ah = root.undescribed.first.att.__handler
      expect(ah.tag).to eq 'att'
      expect(ah.method_name).to eq 'att'
      expect(ah.key).to eq 'att'
      expect(ah.namespace_prefix).to be_nil
      expect(ah.type).to eq String
      expect(ah.described?).to eq false
      expect(ah).to be_a XMLable::Handlers::Attribute

      ch = root.undescribed.first.el.__handler
      expect(ch).to eq root.undescribed.first.el[0].__handler
      expect(ch.tag).to eq 'el'
      expect(ch.method_name).to eq 'el'
      expect(ch.key).to eq 'el'
      expect(ch.namespace_prefix).to be_nil
      expect(ch.type).to eq String
      expect(ch.described?).to eq false
      expect(ch).to be_a XMLable::Handlers::Element
    end
  end
end
