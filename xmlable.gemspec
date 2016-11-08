# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xmlable/version'

Gem::Specification.new do |spec|
  spec.name          = 'xmlable'
  spec.version       = XMLable::VERSION
  spec.authors       = ['Oleg Yashchuk']
  spec.email         = ['oazoer@gmail.com']

  spec.summary       = "XML with Ruby's sugar"
  spec.description   = ''
  spec.license       = 'MIT'

  spec.files         = Dir.glob("{lib}/**/*") + %w[LICENSE.txt README.md]
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '>= 1.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
end
