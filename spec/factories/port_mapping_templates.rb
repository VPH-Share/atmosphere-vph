FactoryGirl.define do
  factory :port_mapping_template, class: 'Atmosphere::PortMappingTemplate' do |f|
    service_name { SecureRandom.hex(4) }
    target_port { Random.rand(9999) }
    appliance_type
  end
end