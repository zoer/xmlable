module XMLable
  #
  # Mixins module contains object mixins modules
  #
  module Mixins
  end
end

require_relative 'mixins/object'
require_relative 'mixins/standalone_element'
require_relative 'mixins/standalone_attribute'
require_relative 'mixins/value_storage'
require_relative 'mixins/elements_storage'
require_relative 'mixins/attributes_storage'
require_relative 'mixins/container'
require_relative 'mixins/content_storage'
require_relative 'mixins/document_storage'
require_relative 'mixins/root_storage'
require_relative 'mixins/options_storage'
require_relative 'mixins/namespace_definitions_storage'
require_relative 'mixins/export'
require_relative 'mixins/bare_value'
require_relative 'mixins/instantiable'
require_relative 'mixins/castable'
require_relative 'mixins/wrapper'
