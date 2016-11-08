RSpec::Matchers.define :has_xpath do |xpath|
  match do |actual|
    Nokogiri::XML(xml(actual)).xpath(xpath).size > 0
  end

  failure_message do |actual|
    "Expected that: \n#{xml(actual)}\n\nto has xpath: #{xpath}"
  end

  failure_message_when_negated do |actual|
    "Expected that: \n#{xml(actual)}\n\nto not has xpath: #{xpath}"
  end

  def xml(obj)
    obj.respond_to?(:to_xml) ? obj.to_xml : obj
  end
end
