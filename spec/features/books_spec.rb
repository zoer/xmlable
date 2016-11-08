require "spec_helper"

RSpec.describe 'fixtures/books.xml' do
  let(:xml) { load_fixture('books.xml') }
  let(:root) { doc.root }
  let(:doc_class) { described_class }
  let(:doc) { doc_class.from_xml(xml)  }
  let(:books) { root.books }
  let(:book1) { books.first }
  let(:book3) { books[2] }
  let(:book12) { books.last }
  let(:json) { JSON.parse(json_raw) }

  let(:book1_desc) { "An in-depth look at creating applications\n      with XML." }

  shared_examples 'export back' do
    it 'export to xml' do
      expect(doc.to_xml).to eq xml
    end

    it 'export to hash' do
      expect(doc.to_json(pretty: true)).to eq JSON.pretty_generate(json)
    end
  end

  describe BooksDocumentSimple do
    let(:json_raw) { load_fixture('books.simple.json') }

    it 'document' do
      expect(doc).to be_a BooksDocumentSimple
      expect(doc.version).to eq "1.0"
      expect(doc.encoding).to be_nil
      expect(doc.root).to eq doc.catalog
      expect(books.size).to eq 12
    end

    it 'first book' do
      expect(book1.id).to be_proxied 'bk101'
      expect(book1.author).to be_proxied 'Gambardella, Matthew'
      expect(book1.title).to be_proxied "XML Developer's Guide"
      expect(book1.genre).to be_proxied 'Computer'
      expect(book1.price).to be_proxied 44.95
      expect(book1.publish_date).to be_proxied Date.parse('2000-10-01')
      expect(book1.description).to be_proxied book1_desc
    end

    it 'first book bare values' do
      expect(book1.id!).to eq 'bk101'
      expect(book1.author!).to eq 'Gambardella, Matthew'
      expect(book1.title!).to eq "XML Developer's Guide"
      expect(book1.genre!).to eq 'Computer'
      expect(book1.price!).to eq 44.95
      expect(book1.publish_date!).to eq Date.parse('2000-10-01')
      expect(book1.description!).to eq book1_desc
    end

    it 'third book' do
      expect(book3.id).to be_proxied 'bk103'
      expect(book3.author).to be_proxied 'Corets, Eva'
      expect(book3.title).to be_proxied 'Maeve Ascendant'
      expect(book3.genre).to be_proxied 'Fantasy'
      expect(book3.price).to be_proxied 5.95
      expect(book3.publish_date).to be_proxied Date.parse('2000-11-17')
      expect(book3.description).to be_proxied \
        "After the collapse of a nanotechnology\n      " \
        "society in England, the young survivors lay the\n      " \
        "foundation for a new society."
    end

    it 'last book' do
      expect(book12.id).to be_proxied 'bk112'
      expect(book12.author).to be_proxied 'Galos, Mike'
      expect(book12.title).to be_proxied 'Visual Studio 7: A Comprehensive Guide'
      expect(book12.genre).to be_proxied 'Computer'
      expect(book12.price).to be_proxied 49.95
      expect(book12.publish_date).to be_proxied Date.parse('2001-04-16')
      expect(book12.description).to be_proxied \
        "Microsoft Visual Studio 7 is explored in depth,\n      " \
        "looking at how Visual Basic, Visual C++, C#, and ASP+ are\n      " \
        "integrated into a comprehensive development\n      environment."
    end

    describe 'export' do
    it 'export to xml' do
      expect(doc.to_xml).to eq xml
    end
      it_behaves_like 'export back'

      context 'when drop settings are given' do
        let(:doc_class) do
          Class.new(described_class) do
            on_export :drop_empty, :drop_undescribed
          end
        end

        it_behaves_like 'export back'
      end
    end
  end

  describe BooksDocumentCasting do
    let(:json_raw) { load_fixture('books.casting.json') }

    it 'document' do
      expect(doc).to be_a BooksDocumentCasting
      expect(books.size).to eq 12
    end

    it 'first book' do
      expect(book1.id).to be_proxied 101
      expect(book1.author).to be_proxied 'Gambardella, Matthew'
      expect(book1.title).to be_proxied "XML Developer's Guide"
      expect(book1.genre).to be_proxied 'Computer'
      expect(book1.price).to be_proxied 44.95
      expect(book1.publish_date).to be_proxied Date.parse('2000-10-01')
      expect(book1.description).to be_proxied \
        "An in-depth look at creating applications with XML."
    end

    it 'export to xml' do
      expect(doc.to_xml).to eq xml
    end
    it_behaves_like 'export back'
  end

  describe BooksDocumentTagsAliases do
    it 'document' do
      expect(doc).to be_a BooksDocumentTagsAliases
      expect(books.size).to eq 12
      expect(doc.root).to eq doc.store
    end

    it 'first book' do
      expect(book1.i).to be_proxied 'bk101'
      expect(book1.a).to be_proxied 'Gambardella, Matthew'
      expect(book1.t).to be_proxied "XML Developer's Guide"
      expect(book1.g).to be_proxied 'Computer'
      expect(book1.pr).to be_proxied 44.95
      expect(book1.pu).to be_proxied Date.parse('2000-10-01')
      expect(book1.d).to be_proxied book1_desc
    end

    it 'export to xml' do
      expect(doc.to_xml).to eq xml
    end
  end

  describe BooksDocumentStanaloneElement do
    it 'document' do
      expect(doc).to be_a BooksDocumentStanaloneElement
      expect(books.size).to eq 12
    end

    it 'first book' do
      expect(book1).to be_a BooksDocumentStanaloneElement::Book
      expect(book1.id).to be_proxied 'prefix-bk101'
      expect(book1.id).to be_a BooksDocumentStanaloneElement::BookId
      expect(book1.author).to be_proxied 'Gambardella, Matthew'
      expect(book1.title).to be_proxied "XML Developer's Guide"
      expect(book1.genre).to be_proxied 'Computer'
      expect(book1.price).to be_proxied 44.95
      expect(book1.publish_date).to be_proxied Date.parse('2000-10-01')
      expect(book1.description).to be_proxied book1_desc
    end

    it 'first book bare values' do
      expect(book1.id!).to eq 'prefix-bk101'
      expect(book1.author!).to eq 'Gambardella, Matthew'
      expect(book1.title!).to eq "XML Developer's Guide"
      expect(book1.genre!).to eq 'Computer'
      expect(book1.price!).to eq 44.95
      expect(book1.publish_date!).to eq Date.parse('2000-10-01')
      expect(book1.description!).to eq book1_desc
    end

    it 'export to xml' do
      expect(doc.to_xml).to eq xml
    end
  end

  describe BooksDocumentDashedKeys do
    let(:json_raw) { load_fixture('books.dashed.json') }
    let(:books) { root['bo-oks'] }
    let(:root) { doc['cat-alog'] }

    it 'document' do
      expect(doc).to be_a BooksDocumentDashedKeys
      expect(doc.version).to eq "1.0"
      expect(doc.encoding).to be_nil
      expect(doc.root).to eq doc['cat-alog']
      expect(books.size).to eq 12
    end

    it 'first book' do
      expect(book1['i-d']).to be_proxied 'bk101'
      expect(book1['auth-or']).to be_proxied 'Gambardella, Matthew'
      expect(book1['tit-le']).to be_proxied "XML Developer's Guide"
      expect(book1['gen-re']).to be_proxied 'Computer'
      expect(book1['pri-ce']).to be_proxied 44.95
      expect(book1['publish-date']).to be_proxied Date.parse('2000-10-01')
      expect(book1['descrip-tion']).to be_proxied book1_desc
    end

    it 'first book bare values' do
      expect(book1['i-d!']).to eq 'bk101'
      expect(book1['auth-or!']).to eq 'Gambardella, Matthew'
      expect(book1['tit-le!']).to eq "XML Developer's Guide"
      expect(book1['gen-re!']).to eq 'Computer'
      expect(book1['pri-ce!']).to eq 44.95
      expect(book1['publish-date!']).to eq Date.parse('2000-10-01')
      expect(book1['descrip-tion!']).to eq book1_desc
    end

    it_behaves_like 'export back'
  end
end
