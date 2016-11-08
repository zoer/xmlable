module XMLable
  #
  # Handlers module contains the handlers objects
  #
  module Handlers
  end
end

require_relative 'handlers/mixins/namespace'
require_relative 'handlers/mixins/described'
require_relative 'handlers/mixins/tag'

require_relative 'handlers/base'
require_relative 'handlers/attribute'
require_relative 'handlers/attribute_none'
require_relative 'handlers/element'
require_relative 'handlers/elements'
require_relative 'handlers/element_none'
require_relative 'handlers/root'
require_relative 'handlers/root_none'
require_relative 'handlers/document'
require_relative 'handlers/namespace'
require_relative 'handlers/storage'
