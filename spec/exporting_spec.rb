require 'spec_helper'

RSpec.describe 'exporting' do
  let(:doc) { klass.from_xml(xml) }
  let(:root) { doc.root }
  let(:to_xml) { doc.to_xml }
  let(:to_json) { doc.to_json }
  let(:to_h) { doc.to_h }

  let(:klass) do
    Class.new do
      include XMLable::Document

      root :catalog
    end
  end
  let(:definition) { '<?xml version="1.0"?>' }
  let(:xml) do
    <<-XML.strip_heredoc.strip
      #{definition}
      <catalog>
        <updated>2014-12-30</updated>
        <item position="1">
          <cost>11</cost>
        </item>
        <item position="2">
          <cost>22</cost>
        </item>
      </catalog>
    XML
  end

  it 'xml' do
    expect(to_xml).to eq xml
  end

  it 'json' do
    expect(to_h).to match_array \
      'catalog' => {
        'updated' => ['2014-12-30'],
        'item' => [
          {'position' => '1', 'cost' => ['11'] },
          {'position' => '2', 'cost' => ['22'] }
        ]
      }
  end

  describe 'drop_undescribed option' do
    context 'when drop_undescribed_attributes is set' do
      let(:klass) do
        Class.new do
          include XMLable::Document

          on_export :drop_undescribed_attributes

          root :catalog
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          #{definition}
          <catalog>
            <updated>2014-12-30</updated>
            <item>
              <cost>11</cost>
            </item>
            <item>
              <cost>22</cost>
            </item>
          </catalog>
        XML
      end

      it 'json' do
        expect(to_h).to match_array \
          'catalog' => {
            'updated' => ['2014-12-30'],
            'item' => [ {'cost' => ['11'] }, {'cost' => ['22'] } ]
          }
      end
    end

    context 'when drop_undescribed_elements is set' do
      let(:xml) do
        <<-XML.strip_heredoc.strip
          #{definition}
          <catalog test="123">
            <updated>2014-12-30</updated>
            <item position="1">
              <cost>11</cost>
            </item>
          </catalog>
        XML
      end
      let(:klass) do
        Class.new do
          include XMLable::Document

          nokogiri_parse :noblanks

          on_export :drop_undescribed_elements

          root :catalog
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          #{definition}
          <catalog test="123"/>
        XML
      end

      it 'json' do
        expect(to_h).to match_array \
          'catalog' => { 'test' => '123' }
      end
    end

    context 'when drop_undescribed is set' do
      let(:klass) do
        Class.new do
          include XMLable::Document

          nokogiri_parse :noblanks

          on_export :drop_undescribed

          root :catalog
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          #{definition}
          <catalog/>
        XML
      end

      it 'json' do
        expect(to_h).to match_array('catalog' => '')
      end
    end
  end

  describe 'drop_empty' do
    let(:xml) do
      <<-XML.strip_heredoc.strip
        #{definition}
        <catalog empty="" full="foo">
          <updated>2014-12-30</updated>
          <item/>
          <item>banana</item>
        </catalog>
      XML
    end

    it 'xml' do
      expect(to_xml).to eq xml
    end

    it 'json' do
      expect(to_h).to match_array \
        'catalog' => {
          'empty' => '',
          'full' => 'foo',
          'updated' => ['2014-12-30'],
          'item' => ['', 'banana']
        }
    end

    context 'when drop_empty_attributes is set' do
      let(:klass) do
        Class.new do
          include XMLable::Document

          on_export :drop_empty_attributes

          root :catalog
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          #{definition}
          <catalog full="foo">
            <updated>2014-12-30</updated>
            <item/>
            <item>banana</item>
          </catalog>
        XML
      end

      it 'json' do
        expect(to_h).to match_array \
          'catalog' => {
            'full' => 'foo',
            'updated' => ['2014-12-30'],
            'item' => ['', 'banana']
          }
      end
    end

    context 'when drop_empty_elements is set' do
      let(:klass) do
        Class.new do
          include XMLable::Document

          nokogiri_parse :noblanks

          on_export :drop_empty_elements

          root :catalog
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          #{definition}
          <catalog empty="" full="foo">
            <updated>2014-12-30</updated>
            <item>banana</item>
          </catalog>
        XML
      end

      it 'json' do
        expect(to_h).to match_array \
          'catalog' => {
            'empty' => '',
            'full' => 'foo',
            'updated' => ['2014-12-30'],
            'item' => ['banana']
          }
      end
    end

    context 'when drop_empty is set' do
      let(:klass) do
        Class.new do
          include XMLable::Document

          nokogiri_parse :noblanks

          on_export :drop_empty

          root :catalog
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          #{definition}
          <catalog full="foo">
            <updated>2014-12-30</updated>
            <item>banana</item>
          </catalog>
        XML
      end

      it 'json' do
        expect(to_h).to match_array \
          'catalog' => {
            'full' => 'foo',
            'updated' => ['2014-12-30'],
            'item' => ['banana']
          }
      end
    end
  end

  describe 'elements content exporing' do
    let(:xml) do
      <<-XML.strip_heredoc.strip
        #{definition}
        <catalog>
          <item0>item0</item0>
          <item1 a="1">item1</item1>
          <item2 a="2">item2</item2>
          <item3 a="3">item3</item3>
          <item4 a="4">item4</item4>
        </catalog>
      XML
    end

    let(:klass) do
      Class.new do
        include XMLable::Document

        root :catalog
      end
    end

    it 'xml' do
      expect(to_xml).to eq xml
    end

    it 'json' do
      expect(to_h).to match_array \
        'catalog' => {
          'item0' => ['item0'],
          'item1' => [{'a' => '1', '__content' => 'item1' }],
          'item2' => [{'a' => '2', '__content' => 'item2' }],
          'item3' => [{'a' => '3', '__content' => 'item3' }],
          'item4' => [{'a' => '4', '__content' => 'item4' }]
        }
    end

    context 'when content is described' do
      let(:klass) do
        Class.new do
          include XMLable::Document

          root :catalog do
            element :item0 do
              content :cont
            end
            element :item1 do
              on_export :drop_undescribed
            end
            element :item2 do
              attribute :a
            end
            element :item3 do
              attribute :a
              content :cont
            end
            element :item4 do
              attribute :a
              content false
            end
          end
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          #{definition}
          <catalog>
            <item0>item0</item0>
            <item1>item1</item1>
            <item2 a="2">item2</item2>
            <item3 a="3">item3</item3>
            <item4 a="4">item4</item4>
          </catalog>
        XML
      end

      it 'json' do
        expect(to_h).to match_array \
          'catalog' => {
            'item0' => 'item0',
            'item1' => 'item1',
            'item2' => {'a' => '2', '__content' => 'item2' },
            'item3' => {'a' => '3', 'cont' => 'item3' },
            'item4' => {'a' => '4'}
          }
      end
    end
  end

  describe 'nokogiri export/parse settings' do
    let(:xml) do
      <<-XML.strip_heredoc.strip
        #{definition}
        <catalog>
          <item a=""/>
        </catalog>
      XML
    end

    let(:klass) do
      Class.new do
        include XMLable::Document
      end
    end

    it 'xml' do
      expect(to_xml).to eq xml
    end

    it 'json' do
      expect(to_h).to match_array \
        'catalog' => { 'item' => [{'a' => ''}] }
    end

    context 'no_declaration' do
      let(:klass) do
        Class.new do
          include XMLable::Document

          nokogiri_export :no_declaration
        end
      end

      it 'xml' do
        expect(to_xml).to eq <<-XML.strip_heredoc.strip
          <catalog>
            <item a=""/>
          </catalog>
        XML
      end

      it 'json' do
        expect(to_h).to match_array \
          'catalog' => { 'item' => [{'a' => ''}] }
      end

      context 'noblanks' do
        let(:klass) do
          Class.new do
            include XMLable::Document

            nokogiri_parse :noblanks
            nokogiri_export :no_declaration
          end
        end

        it 'xml' do
          expect(to_xml).to eq <<-XML.strip_heredoc.strip
            <catalog><item a=""/></catalog>
          XML
        end

        it 'json' do
          expect(to_h).to match_array \
            'catalog' => { 'item' => [{'a' => ''}] }
        end

        context 'noblanks' do
          let(:klass) do
            Class.new do
              include XMLable::Document

              nokogiri_parse :noblanks
              nokogiri_export :no_declaration, :format
            end
          end

          it 'xml' do
            expect(to_xml).to eq <<-XML.strip_heredoc.strip
              <catalog>
                <item a=""/>
              </catalog>
            XML
          end

          it 'json' do
            expect(to_h).to match_array \
              'catalog' => { 'item' => [{'a' => ''}] }
          end
        end
      end
    end
  end
end
