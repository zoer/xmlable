require 'spec_helper'

RSpec.describe 'Initialization' do
  let(:doc) { klass.new(catalog: hash) }
  let(:root) { doc.root }
  let(:klass) do
    Class.new do
      include XMLable::Document

      root :catalog do
        attribute :stale, :bool
        element :size, :int
        elements :items, tag: 'item' do
          attribute :position, :int
          element :title
          element :desc, tag: 'description'
          element :amount, :int
        end
      end
    end
  end
  let(:hash) do
    {
      stale: true,
      size: 10,
      items: [
        { title: 't-shirt', desc: 'white t-shirt', position: 1, amount: 482 },
        { title: 'shoes', desc: 'black shoes', position: 2 }
      ]
    }
  end

  let(:output) do
    <<-XML.strip_heredoc.strip
      <?xml version="1.0"?>
      <catalog stale="true">
        <size>10</size>
        <item position="1">
          <title>t-shirt</title>
          <description>white t-shirt</description>
          <amount>482</amount>
        </item>
        <item position="2">
          <title>shoes</title>
          <description>black shoes</description>
        </item>
      </catalog>
    XML
  end

  it 'should initialize correctly' do
    expect(root.stale).to be_proxied true
    expect(root.size).to be_proxied 10
    expect(root.items.size).to eq 2
    expect(root.items[0].title).to be_proxied 't-shirt'
    expect(root.items[0].desc).to be_proxied 'white t-shirt'
    expect(root.items[0].position).to be_proxied 1
    expect(root.items[0].amount).to be_proxied 482
    expect(root.items[1].title).to be_proxied 'shoes'
    expect(root.items[1].desc).to be_proxied 'black shoes'
    expect(root.items[1].position).to be_proxied 2
    expect(root.items[1].amount).to be_proxied 0
  end

  it 'should export as expected' do
    expect(doc.to_xml).to eq output
  end
end
