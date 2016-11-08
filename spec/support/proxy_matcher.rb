RSpec::Matchers.define :be_proxied do |expected|
  match do |actual|
    value = actual.__object
    actual.to_s == expected.to_s &&
      value.class == expected.class &&
      value == expected
  end

  failure_message do |actual|
    value = actual.__object
    "Compare casted string: #{actual.to_s.inspect} == #{expected.to_s.inspect}\n" \
      "Compare classes:       #{value.class} == #{expected.class}\n" \
      "Compare bare values:   #{value.inspect} == #{expected.inspect}"
  end
end
