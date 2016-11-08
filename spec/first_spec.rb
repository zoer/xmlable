require "spec_helper"

RSpec.describe XMLable do
  describe 'simple' do
    let(:bill_date) { Date.new(2016, 10, 20) }
    let(:status_content) { 'paid' }
    let(:dynamic_content) { true }

    let(:xml) do
      <<-XML
        <?xml version="1.0"?>
        <bill date="#{bill_date}">
          <status approved="1">#{status_content}</status>
          <dynamic count="3">#{dynamic_content}</dynamic>
          <item position="1">
            <cost>12.1</cost>
          </item>
          <item position="2">
            <cost>2.1</cost>
          </item>
        </bill>
      XML
    end

    let(:bill) { document.bill }
    let(:root) { document.root }
    let(:items) { bill.items }

    describe 'when described' do
      class TestParse
        include XMLable::Document

        before_export { |el| super(el) || !el.described? || !el.__empty? }
        on_export :drop_undescribed, :drop_empties

        root :bill do
          attribute :date, Date
          element :status do
            attribute :approved, :bool
          end

          elements :items, :string, tag: 'item' do
            attribute :position, :integer
            element :cost, :float
          end
        end
      end

      let(:document) { TestParse.from_xml(xml) }

      it 'document and root' do
        expect(document).to be_a(TestParse)
        expect(root).to eq bill
      end

      it 'root elements and attributes' do
        expect(bill.date).to be_proxied bill_date
        expect(bill.status).to be_proxied status_content
        expect(bill.status.approved).to be_proxied true
      end

      it 'get direct values' do
        expect(bill.date!).to eq bill_date
        expect(bill.status!).to eq status_content
        expect(bill.status.approved!).to eq true
        expect(bill.dynamic![0]).to eq dynamic_content.to_s
        expect(bill.dynamic[0].count!).to eq '3'
      end

      it "when element or attribute isn't described" do
        expect(bill.dynamic.size).to eq 1
        expect(bill.dynamic[0]).to be_proxied dynamic_content.to_s
        dyn = bill.dynamic[0]
        expect(dyn.count).to be_proxied '3'
      end

      it 'when multiple elements are described' do
        expect(items.size).to eq 2
        expect(items[0].cost).to be_proxied 12.1
        expect(items[0].position).to be_proxied 1
        expect(items[1].cost).to be_proxied 2.1
        expect(items[1].position).to be_proxied 2
      end
    end

    describe 'when just the root described' do
      class TestParseJustRootDescribed
        include XMLable

        root :bill
      end

      let(:document) { TestParseJustRootDescribed.from_xml(xml) }
      let(:items) { bill.item }

      it 'root' do
        expect(document).to be_a(TestParseJustRootDescribed)
        expect(root).to eq bill
      end

      it 'root elements and attrbutes' do
        expect(bill.date).to be_proxied bill_date.to_s
        expect(bill.status.size).to eq 1
        expect(bill.status[0]).to be_proxied status_content
        expect(bill.status[0].approved).to be_proxied '1'
      end

      it 'when multiple tags' do
        expect(items.size).to eq 2
        expect(items[0].cost[0]).to be_proxied '12.1'
        expect(items[0].position).to be_proxied '1'
        expect(items[1].cost[0]).to be_proxied '2.1'
        expect(items[1].position).to be_proxied '2'
      end
    end
  end

  describe 'element classes' do
    let(:xml) do
      <<-XML
        <?xml version="1.0"?>
        <status>
          <entity position="1">first</entity>
          <entity position="2">second</entity>
        </status>
      XML
    end

    class TestEntity
      include XMLable

      tag :entity
      attribute :position, Integer
    end

    class TestContainer
      include XMLable

      root :status do
        elements :entities, TestEntity, tag: 'entity'
      end
    end

    let(:document) { TestContainer.from_xml(xml) }
    let(:root) { document.root }
    let(:t) { TestEntity.new }

    it 'document' do
      expect(document).to be_a(TestContainer)
    end
  end
end
