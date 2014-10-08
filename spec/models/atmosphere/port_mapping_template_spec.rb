require 'rails_helper'

describe Atmosphere::PortMappingTemplate do
  describe 'manage metadata' do
    let!(:endp11) { build(:endpoint, description: 'FIRST ENDP') }
    let!(:endp12) { build(:endpoint, description: 'ENDP_DESC') }
    let!(:endp21) { build(:endpoint) }
    let!(:pmt1) { build(:port_mapping_template, endpoints: [endp11, endp12]) }
    let!(:pmt2) { build(:port_mapping_template, endpoints: [endp21]) }
    let!(:pmt3) { build(:port_mapping_template) }
    let!(:pmt5) { build(:port_mapping_template) }
    let!(:complex_at) { create(:appliance_type, port_mapping_templates: [pmt1, pmt5], visible_to: :all, name: 'complex_at') }

    let!(:endp41) { build(:endpoint) }
    let!(:pmt4) { build(:port_mapping_template, endpoints: [endp41]) }
    let!(:private_complex_at) { create(:appliance_type, port_mapping_templates: [pmt4], visible_to: :owner) }

    it 'updates metadata when PMT destroyed' do
      expect(MetadataRepositoryClient.instance).to receive(:update_appliance_type).with(complex_at).twice
      pmt1.destroy
    end

    it 'updates metadata when PMT with endpoint added' do
      expect(MetadataRepositoryClient.instance).to receive(:update_appliance_type).with(complex_at)
      complex_at.port_mapping_templates << pmt2
    end

    it 'does not update metadata when empty PMT added' do
      expect(MetadataRepositoryClient.instance).not_to receive(:update_appliance_type)
      complex_at.port_mapping_templates << pmt3
    end

    it 'does not update metadata when empty PMT destroyed' do
      expect(MetadataRepositoryClient.instance).not_to receive(:update_appliance_type)
      pmt5.destroy
    end

    it 'does not update appliance metadata when not published' do
      expect(MetadataRepositoryClient.instance).not_to receive(:update_appliance_type)
      pmt4.destroy
    end
  end
end