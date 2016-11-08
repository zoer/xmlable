RSpec::Matchers.define :has_namespace do |expected|
  match do |actual|
    prefix = actual.__node.namespace.prefix if actual.__node.namespace
    prefix.to_s == expected.to_s &&
      actual.__handler.namespace_prefix.to_s == expected.to_s
  end

  failure_message do |actual|
    "Element doesn't have give namespace: #{expected.inspect}\n" \
      "Node's namespace: #{actual.__node.namespace.inspect}\n" \
      "Handler's namespace: #{actual.__handler.namespace_prefix}\n"
  end
end

RSpec::Matchers.define :has_default_namespace do
  match do |actual|
    prefix = actual.__node.namespace.prefix if actual.__node.namespace
    prefix == nil
  end

  failure_message do |actual|
    "Element has default namespace\n" \
      "Node's namespace: #{actual.__node.namespace.inspect}\n" \
      "Handler's namespace: #{actual.__handler.namespace_prefix}\n"
  end
end

RSpec::Matchers.define :defines_namespace do |expected|
  match do |actual|
    expected = expected.to_s if expected.is_a?(Symbol)
    definitions = actual.__namespace_definitions
    ns = definitions.find { |n| n.prefix == expected }
    return ns unless href_defined?
    ns ? ns.href == @href : false
  end

  chain :with_href do |href|
    @href = href
  end

  define_method :href_defined? do
    instance_variable_defined?(:@href)
  end

  failure_message do |actual|
    definitions = actual.__namespace_definitions
    href = " with href #{@href.inspect}" if href_defined?
    message = "Expect element has definition of the #{expected.inspect} namespace" \
      "#{href}, but it's not!\n"
    if definitions.size > 0
      definitions.each { |n| message << n.inspect << "\n" }
    else
      message << "Element doesn't have any namespace definition."
    end
    message
  end
end
