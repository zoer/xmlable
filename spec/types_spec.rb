require 'spec_helper'

RSpec.describe 'types' do
  let(:builder) { XMLable::Builder }
  let(:handler) { XMLable::Handlers::AttributeNone.build(:foo, :test) }

  def xml(val)
    <<-XML.strip_heredoc.strip
      <?xml version="1.0"?>
      <root>
        <object>#{val}</object>
        <foo>foo</foo>
      </root>
    XML
  end

  describe 'define new type' do
    let(:type) { :test }
    let(:val) { 1 }
    let(:klass) do
      obj_type = type
      Class.new do |k|
        include XMLable::Document

        nokogiri_parse :noblanks
        nokogiri_export :no_declaration

        on_export :drop_empty

        root :root do
          element :object, obj_type
          element :foo
        end
      end
    end

    before(:example) do
      builder.define_type type do
        cast { |v| "cast: #{v}" }
        export_to_xml  { |v| "export_to_xml: #{v}" }
        export_to_json { |v| "export_to_json: #{v}" }
        empty { |v| v.to_s != 'cast: 1' }
      end
    end

    after(:example) do
      builder.instance.defined_types.delete(:test)
    end

    it 'should behave like described' do
      doc = klass.from_xml(xml(val))
      expect(doc).to has_xpath("//root/object[text() = '#{val}']")

      doc.root.object = val
      expect(doc).to has_xpath("//root/object[text() = 'export_to_xml: cast: #{val}']")
      expect(doc.to_h['root']).to include('object' => "export_to_json: cast: #{val}")
      expect(doc.root.object.__empty?).to eq false

      doc.root.object = 2
      expect(doc.to_xml).to_not has_xpath('//root/object')
      expect(doc.to_h['root']).to_not include('object')
      expect(doc.root.object.__empty?).to eq true
    end
  end

  describe 'test registred types' do
    let(:klass) do
      obj_type = type
      Class.new do |k|
        include XMLable::Document

        root :root do
          element :object, obj_type
          element :foo
        end
      end
    end
    let(:klass_drop_empty) do
      obj_type = type
      Class.new do |k|
        include XMLable::Document

        on_export :drop_empty

        root :root do
          element :object, obj_type
          element :foo
        end
      end
    end

    let(:doc) { klass.from_xml(xml(val)) }
    let(:doc_drop_empty) { klass_drop_empty.from_xml(xml(val)) }

    describe 'string' do
      shared_examples 'string type' do |t|
        let(:type) { t }
        let(:val) { '' }

        it 'should not cast XML value on import' do
          expect(doc).to has_xpath('//object[not(text())]')
        end

        context "when type is #{t.inspect}" do
          it 'value is ""' do
            expect(doc.to_h['root']).to include('object' => '')
            expect(doc).to has_xpath('//object[not(text())]')

            expect(doc_drop_empty).to_not has_xpath('//root/object')
            expect(doc_drop_empty.to_h).to_not include("object")
          end

          context 'value is "1"' do
            let(:val) { '1' }

            it 'should work' do
              expect(doc).to has_xpath('//root/object[text() = "1"]')
              expect(doc.to_h['root']).to include('object' => '1')

              expect(doc_drop_empty).to has_xpath('//root/object[text() = "1"]')
              expect(doc_drop_empty.to_h['root']).to include('object' => '1')
            end
          end
        end
      end

      [String, 'str', 'string', :str, :string].each do |t|
        it_behaves_like 'string type', t
      end
    end

    describe 'integer' do
      shared_examples 'integer type' do |t|
        let(:type) { t }
        let(:val) { '' }

        it 'should not cast XML value on import' do
          expect(doc).to has_xpath('//object[not(text())]')
        end

        context "when type is #{t.inspect}" do
          before(:example) do
            doc.root.object = val
            doc_drop_empty.root.object = val
          end

          it 'value is ""' do
            expect(doc.to_h['root']).to include('object' => 0)
            expect(doc).to has_xpath('//object[text() = 0]')

            expect(doc_drop_empty).to has_xpath('//root/object')
            expect(doc_drop_empty.to_h).to_not include("object")
          end

          context 'value is "1"' do
            let(:val) { '1' }

            it 'should work' do
              expect(doc).to has_xpath('//root/object[text() = "1"]')
              expect(doc.to_h['root']).to include('object' => 1)

              expect(doc_drop_empty).to has_xpath('//root/object[text() = "1"]')
              expect(doc_drop_empty.to_h['root']).to include('object' => 1)
            end
          end

          context 'value is "1.1"' do
            let(:val) { '1.1' }

            it 'should work' do
              expect(doc).to has_xpath('//root/object[text() = "1"]')
              expect(doc.to_h['root']).to include('object' => 1)

              expect(doc_drop_empty).to has_xpath('//root/object[text() = "1"]')
              expect(doc_drop_empty.to_h['root']).to include('object' => 1)
            end
          end
        end
      end

      [Integer, 'int', 'integer', :int, :integer].each do |t|
        it_behaves_like 'integer type', t
      end
    end

    describe 'float' do
      shared_examples 'float type' do |t|
        let(:type) { t }
        let(:val) { '' }

        it 'should not cast XML value on import' do
          expect(doc).to has_xpath('//object[not(text())]')
        end

        context "when type is #{t.inspect}" do
          before(:example) do
            doc.root.object = val
            doc_drop_empty.root.object = val
          end

          it 'value is ""' do
            expect(doc.to_h['root']).to include('object' => 0.0)
            expect(doc).to has_xpath('//object[text() = 0.0]')

            expect(doc_drop_empty).to has_xpath('//root/object')
            expect(doc_drop_empty.to_h).to_not include("object")
          end

          context 'value is "1"' do
            let(:val) { '1' }

            it 'should work' do
              expect(doc).to has_xpath('//root/object[text() = "1.0"]')
              expect(doc.to_h['root']).to include('object' => 1.0)

              expect(doc_drop_empty).to has_xpath('//root/object[text() = "1.0"]')
              expect(doc_drop_empty.to_h['root']).to include('object' => 1.0)
            end
          end

          context 'value is "1.1"' do
            let(:val) { '1.1' }

            it 'should work' do
              expect(doc).to has_xpath('//root/object[text() = "1.1"]')
              expect(doc.to_h['root']).to include('object' => 1.1)

              expect(doc_drop_empty).to has_xpath('//root/object[text() = "1.1"]')
              expect(doc_drop_empty.to_h['root']).to include('object' => 1.1)
            end
          end
        end
      end

      [Float, :float, 'float'].each do |t|
        it_behaves_like 'float type', t
      end
    end

    describe 'boolean' do
      shared_examples 'boolean type' do |t|
        let(:type) { t }
        let(:val) { '' }

        it 'should not cast XML value on import' do
          expect(doc).to has_xpath('//object[not(text())]')
        end

        context "when type is #{t.inspect}" do
          before(:example) do
            doc.root.object = val
            doc_drop_empty.root.object = val
          end

          it 'value is ""' do
            expect(doc.to_h['root']).to include('object' => false)
            expect(doc).to has_xpath('//object[text() = "false"]')

            expect(doc_drop_empty).to has_xpath('//root/object')
            expect(doc_drop_empty.to_h).to_not include("object")
          end

          context 'value is "1"' do
            let(:val) { '1' }

            it 'should work' do
              expect(doc).to has_xpath('//root/object[text() = "true"]')
              expect(doc.to_h['root']).to include('object' => true)

              expect(doc_drop_empty).to has_xpath('//root/object[text() = "true"]')
              expect(doc_drop_empty.to_h['root']).to include('object' => true)
            end
          end

          context 'value is "0"' do
            let(:val) { '0' }

            it 'should work' do
              expect(doc).to has_xpath('//root/object[text() = "false"]')
              expect(doc.to_h['root']).to include('object' => false)

              expect(doc_drop_empty).to has_xpath('//root/object[text() = "false"]')
              expect(doc_drop_empty.to_h['root']).to include('object' => false)
            end
          end
        end
      end

      [:bool, :boolean, 'boolean', 'bool'].each do |t|
        it_behaves_like 'boolean type', t
      end
    end
  end
end
