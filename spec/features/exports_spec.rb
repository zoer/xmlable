require "spec_helper"

RSpec.describe XMLable::Exports::XMLExporter do
  let(:input_xml) { load_fixture('exports.xml') }
  let(:xml) { input_xml }
  let(:doc) { klass.from_xml(input_xml) }
  let(:klass) { described_class }
  let(:hash) { JSON.parse(json) }

  shared_examples 'export' do
    it 'xml' do
      expect(xml).to eq doc.to_xml
    end

    it 'json' do
      expect(doc.to_json(pretty: true)).to eq json
    end
  end

  describe ExportsFullyDescribed do
    let(:json) { load_fixture('exports.fully_described.json') }

    it_behaves_like 'export'

    context 'when drop_undescribed is set' do
      let(:json) { load_fixture('exports.fully_described.drop_undescribed.json') }

      let(:klass) do
        Class.new(described_class) do
          on_export :drop_undescribed
        end
      end

      it_behaves_like 'export'
    end

    context 'when drop_empty is set' do
      let(:json) { load_fixture('exports.fully_described.drop_empty.json') }
      let(:xml) { load_fixture('exports.fully_described.drop_empty.xml') }
      let(:klass) do
        Class.new(described_class) do
          on_export :drop_empty
        end
      end

      it_behaves_like 'export'
    end
  end

  describe ExportsPartiallyDescribed do
    let(:json) { load_fixture('exports.fully_described.json') }
    let(:hash) { JSON.parse(json) }

    it_behaves_like 'export'

    context 'when drop_undescribed is set' do
      let(:json) { load_fixture('exports.partially_described.json') }
      let(:xml) { load_fixture('exports.partially_described.xml') }
      let(:klass) do
        Class.new(described_class) do
          on_export :drop_undescribed
        end
      end

      it_behaves_like 'export'
    end
  end
end
