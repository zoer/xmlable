# XMLable
[![Build Status](https://travis-ci.org/zoer/xmlable.svg)](https://travis-ci.org/zoer/xmlable)
[![Code Climate](https://codeclimate.com/github/zoer/xmlable/badges/gpa.svg)](https://codeclimate.com/github/zoer/xmlable)
[![Version Eye](https://www.versioneye.com/ruby/xmlable/badge.png)](https://www.versioneye.com/ruby/xmlable)
[![Inline docs](http://inch-ci.org/github/zoer/xmlable.png)](http://inch-ci.org/github/zoer/xmlable)
[![Gem Version](https://badge.fury.io/rb/xmlable.svg)](http://badge.fury.io/rb/xmlable)

XMLable provides an ability to convert XML to Ruby object and back.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xmlable'
```

## Examples

### Basic usage
```ruby
# Describe XML structure
class Catalog
  include XMLable::Document

  root :catalog do
    attribute :date, Date
    element :size, Integer
    elements :items, tag: 'item' do
      attribute :position, Integer
      element :title
      element :desc, tag: 'description'
      element :amount, Integer
    end
  end
end

xml = <<-XML
<?xml version="1.0"?>
<catalog date="2014-12-20">
  <size>10</size>
  <item position="1">
    <title>Sumac Shoes</title>
    <description>Capture the beauty</description>
    <amount>3</amount>
  </item>
  <item position="2">
    <title>Channing Oxford Shoes</title>
    <description>Hand finished with a wash of color</description>
  </item>
</catalog>
XML

doc = Catalog.from_xml(xml)
doc.catalog.date # => #<Date: 2014-12-20 ((2457012j,0s,0n),+0s,2299161j)>
doc.catalog.size # => 10
doc.catalog.items.size # => 2
doc.catalog.items[0].title # => "Sumac Shoes"
doc.catalog.items[0].desc # => "Capture the beauty"
doc.catalog.items[0].amount # => 3
doc.catalog.items[0].position # => 1

doc.to_json
#{
#  "catalog": {
#    "date": "2014-12-20",
#    "size": 10,
#    "items": [
#      { "title": "Sumac Shoes", "desc": "Capture the beauty", "amount": 3, "position": 1 },
#      { "title": "Channing Oxford Shoes", "desc": "Hand finished with a wash of color", "position": 2 }
#    ]
#  }
#}

json = {
  catalog: {
    date: "2014-12-20",
    size: 10,
    items: [
      { title: "Sumac Shoes", desc: "Capture the beauty", amount: 3, position: 1 },
      { title: "Channing Oxford Shoes", desc: "Hand finished with a wash of color", position: 2 }
    ]
  }
}

# Initialize with JSON
doc = Catalog.new(json)
doc.catalog.date # => #<Date: 2014-12-20 ((2457012j,0s,0n),+0s,2299161j)>
doc.catalog.size # => 10
doc.catalog.items.size # => 2
doc.catalog.items[0].title # => "Sumac Shoes"
doc.catalog.items[0].desc # => "Capture the beauty"
doc.catalog.items[0].amount # => 3
doc.catalog.items[0].position # => 1

# By default all elements and attribute values are proxied. If you for some
# reason need to get real value just use the exclamation mark.
doc.catalog.date! # => #<Date: 2014-12-20 ((2457012j,0s,0n),+0s,2299161j)>

doc.to_xml
#<?xml version="1.0"?>
#<catalog date="2014-12-20">
#  <size>10</size>
#  <item position="1">
#    <title>Sumac Shoes</title>
#    <description>Capture the beauty</description>
#    <amount>3</amount>
#  </item>
#  <item position="2">
#    <title>Channing Oxford Shoes</title>
#    <description>Hand finished with a wash of color</description>
#  </item>
#</catalog>
```

### XML with namespaces
```ruby
xml = <<-XML
<?xml version="1.0"?>
<d:student xmlns="http://example.com" xmlns:d="http://foo.com/student" d:id="11">
  <d:name d:position="2">Jeff Smith</d:name>
  <info>
    <city number="7">Beijing</city>
  </info>
</d:student>
XML

class Student
  include XMLable::Document

  root :student, namespace: 'd' do
    namespace nil, 'http://example.com'
    # the last defined namespace will be set as default for the all following
    # and nested elements and attributes. If you need to overwrite namespace
    # just pass namespace: 'prefix' (see the root definition above).
    namespace :d, 'http://foo.com/student'

    attribute :id, :int

    element :name do
      attribute :position, :int
      # You can describe content method of element which has also attributes
      # besides the content. By default content if present will be exported into JSON with
      # '__content' key. You can pase 'false' instead of name to ignore it.
      content :fullname
    end

    # If namespace setting is passed it will be set as default for the all
    # nested element and attributes.
    element :info, namespace: nil do
      element :city do
        attribute :number, Integer
        content :name
      end
    end
  end
end

student = Student.from_xml(xml)
student.to_json
#{
#  "student": {
#    "id": 11,
#    "name": {
#      "fullname": "Jeff Smith",
#      "position": 2
#    },
#    "info": {
#      "city": {
#        "name": "Beijing",
#        "number": 7
#      }
#    }
#  }
#}

# Back direction
other = Student.new(student.to_h)

other.to_xml
#<?xml version="1.0"?>
#<d:student xmlns="http://example.com" xmlns:d="http://foo.com/student" d:id="11">
#  <d:name d:position="2">Jeff Smith</d:name>
#  <info>
#    <city number="7">Beijing</city>
#  </info>
#</d:student>
```

### Undescribed document
It's also possible to load undescribed XML. In this case each XML element(not
attribute) will be represented as an array, so you have to use indexes to
access element values.
```ruby
xml = <<-XML
<?xml version="1.0"?>
<item id="11">
  <name position="2">Bolt</name>
  <info>
    <color>Silver</color>
  </info>
</item>
XML

class Item
  include XMLable::Document
end

item = Item.from_xml(xml)

item.root.id # => "11"
item.root.name[0].position # => "2"
item.root.name[0] # => "Bolt"
item.root.info[0].color[0] # => "Silver"

item.to_h
#{
#  "item": {
#    "id": "11"
#    "name": [{"position": 2", "__content": "Bolt"}]
#    "info": [{ "color": ["Silver"]}]
#  }
#}

item.to_xml
#<?xml version="1.0"?>
#<item id="11">
#  <name position="2">Bolt</name>
#  <info>
#    <color>Silver</color>
#  </info>
#</item>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zoer/xmlable.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

