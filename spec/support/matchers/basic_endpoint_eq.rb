RSpec::Matchers.define :basic_endpoint_eq do |expected|
  match do |actual|
    (actual['id'] == expected.id) &&
    (actual['name'] == expected.name) &&
    (actual['description'] == expected.description) &&
    (actual['endpoint_type'] == expected.endpoint_type.to_s) &&
    (actual['url'] == atmosphere.descriptor_api_v1_endpoint_url(expected.id))
  end
end