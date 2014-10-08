module Atmosphere::EndpointExt
  extend ActiveSupport::Concern

  included do
    include EscapeXml

    around_update :manage_metadata
    after_destroy :update_appliance_metadata, if: 'port_mapping_template.appliance_type and port_mapping_template.appliance_type.publishable?'
    after_create :update_appliance_metadata, if: 'port_mapping_template.appliance_type and port_mapping_template.appliance_type.publishable?'
  end

  # This method is used to produce XML document that is being sent to the Metadata Registry
  def as_metadata_xml
    <<-MD_XML.strip_heredoc
      <endpoint>
        <endpointID>#{id}</endpointID>
        <name>#{esc_xml name}</name>
        <description>#{esc_xml description}</description>
      </endpoint>
    MD_XML
  end

  private

  # METADATA lifecycle methods

  # Check if we need to update metadata regarding this endpoint's AT, if so, perform the task
  def manage_metadata
    old_pmt = port_mapping_template_id_changed? ? Atmosphere::PortMappingTemplate.find(port_mapping_template_id_was) : nil
    yield
    port_mapping_template.appliance_type.update_metadata if port_mapping_template.appliance_type and port_mapping_template.appliance_type.publishable?
    if old_pmt and old_pmt.appliance_type and (old_pmt.appliance_type != port_mapping_template.appliance_type) and old_pmt.appliance_type.publishable?
      old_pmt.appliance_type.update_metadata
    end
  end

  def update_appliance_metadata
    port_mapping_template.appliance_type.update_metadata
  end
end