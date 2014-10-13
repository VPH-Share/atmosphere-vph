RSpec::Matchers.define :basic_appliance_type_eq do |expected|
  match do |actual|
    actual['id'] == expected.id &&
    actual['name'] == expected.name &&
    actual['description'] == expected.description
  end
end
