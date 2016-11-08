class BooksDocumentSimple
  include [XMLable, XMLable::Document].sample

  document
  on_export :drop_empty, :drop_undescribed

  root :catalog do
    elements :books, tag: 'book' do
      attribute :id
      element :author, :str
      element :title, :string
      element :genre, 'string'
      element :price, Float
      element :publish_date, Date
      element :description, String
    end
  end
end

class BooksDocumentCasting
  include [XMLable, XMLable::Document].sample

  root :catalog do
    elements :books, tag: 'book' do
      attribute :id, :int do
        cast { |v| v.to_s.gsub(/\D+/, '').to_i }
      end
      element :author
      element :title
      element :genre
      element :price, Float
      element :publish_date, Date
      element :description do
        cast { |val| val.to_s.gsub(/\s{2,}/, ' ') }
      end
    end
  end
end

class BooksDocumentTagsAliases
  include [XMLable, XMLable::Document].sample

  root :store, tag: 'catalog' do
    elements :books, tag: 'book' do
      attribute :i, tag: 'id'
      element :a, tag: 'author'
      element :t, tag: 'title'
      element :g, 'string', tag: 'genre'
      element :pr, Float, tag: 'price'
      element :pu, Date, tag: 'publish_date'
      element :d, tag: 'description'
    end
  end
end

class BooksDocumentStanaloneElement
  include [XMLable, XMLable::Document].sample

  class BookId
    include [XMLable, XMLable::Attribute].sample

    attr_name :id

    cast { |val| "prefix-#{val}" }
  end

  class Book
    include [XMLable, XMLable::Element].sample

    tag :book

    attribute :id, BookId
    element :author
    element :title
    element :genre
    element :price, :float
    element :publish_date, Date
    element :description
  end

  root :catalog do
    elements :books, Book
  end
end

class BooksDocumentDashedKeys
  include XMLable::Document

  on_export :drop_empty, :drop_undescribed

  root :'cat-alog', tag: 'catalog' do
    elements :'bo-oks', tag: 'book' do
      attribute :'i-d', tag: 'id'
      element :'auth-or', :str, tag: 'author'
      element :'tit-le', :string, tag: 'title'
      element :'gen-re', 'string', tag: 'genre'
      element :'pri-ce', Float, tag: 'price'
      element :'publish-date', Date, tag: 'publish_date'
      element :'descrip-tion', String, tag: 'description'
    end
  end
end
