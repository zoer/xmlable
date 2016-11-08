require 'rubygems'
require 'singleton'
require 'nokogiri'
require 'json'
require 'date'

#
# XMLable provides an ability to handle XML objects with Ruby's classes.
#
module XMLable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    %i[document root].each do |m|
      define_method m do |*args, &block|
        include XMLable::Document
        send(__method__, *args, &block)
      end
    end

    %i[element elements tag].each do |m|
      define_method m do |*args, &block|
        include XMLable::Element
        send(__method__, *args, &block)
      end
    end

    def attr_name(*args, &block)
      include XMLable::Attribute
      send(__method__, *args, &block)
    end
  end
end

require 'xmlable/version'

require_relative 'xmlable/builder'
require_relative 'xmlable/handlers'
require_relative 'xmlable/mixins'

require_relative 'xmlable/document'
require_relative 'xmlable/element'
require_relative 'xmlable/attribute'
require_relative 'xmlable/options'

require_relative 'xmlable/exports'
require_relative 'xmlable/types'
