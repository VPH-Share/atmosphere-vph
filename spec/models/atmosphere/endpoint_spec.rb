require 'rails_helper'

describe Atmosphere::Endpoint do
  describe 'as_metadata_xml' do
    let(:endp) { create(:endpoint) }
    let(:evil_endp) { create(:endpoint, description: '</endpointDescription>') }

    it 'creates minimal valid metadata xml document' do
      xml = endp.as_metadata_xml.strip
      expect(xml).to start_with('<endpoint>')
      expect(xml).to include('<name>'+endp.name+'</name>')
      expect(xml).to include('<endpointID>'+endp.id.to_s+'</endpointID>')
      expect(xml).to include('<description></description>')
      expect(xml).to end_with('</endpoint>')
    end

    it 'escapes XML content for proper document structure' do
      xml = evil_endp.as_metadata_xml.strip
      expect(xml).to include('<description>&lt;/endpointDescription&gt;</description>')
    end
  end

  describe 'manage metadata' do
    let!(:endp11) { build(:endpoint, description: 'FIRST ENDP') }
    let!(:endp12) { build(:endpoint, description: 'ENDP_DESC') }
    let!(:endp21) { build(:endpoint) }
    let!(:pmt1) { build(:port_mapping_template, endpoints: [endp11, endp12]) }
    let!(:pmt2) { build(:port_mapping_template, endpoints: [endp21]) }
    let!(:pmt3) { build(:port_mapping_template) }
    let!(:other_pmt) { build(:port_mapping_template) }
    let!(:complex_at) { create(:appliance_type, port_mapping_templates: [pmt1, pmt2, pmt3], visible_to: :all, name: 'complex_at') }
    let!(:other_complex_at) { create(:appliance_type, port_mapping_templates: [other_pmt], visible_to: :developer, name: 'other_complex_at') }

    let!(:endp41) { build(:endpoint) }
    let!(:pmt4) { build(:port_mapping_template, endpoints: [endp41]) }
    let!(:private_complex_at) { create(:appliance_type, port_mapping_templates: [pmt4], visible_to: :owner) }

    it 'updates metadata when endpoint information changed' do
      allow(endp11).to receive(:port_mapping_template).and_return(pmt1)
      allow(pmt1).to receive(:appliance_type).and_return(complex_at)
      expect(complex_at).to receive(:update_metadata)
      endp11.description = 'sth else'
      endp11.save
    end

    it 'updates metadata when endpoint switched to different PMT' do
      expect(MetadataRepositoryClient.instance).to receive(:update_appliance_type).twice
      endp11.port_mapping_template = other_pmt
      endp11.save
      expect(complex_at.reload.as_metadata_xml.strip).not_to include('FIRST ENDP')
      expect(other_complex_at.reload.as_metadata_xml.strip).to include('FIRST ENDP')
    end

    it 'updates metadata when endpoint destroyed' do
      expect(MetadataRepositoryClient.instance).to receive(:update_appliance_type).with(complex_at)
      endp11.destroy
    end

    it 'updates metadata when endpoint added' do
      expect(MetadataRepositoryClient.instance).to receive(:update_appliance_type).with(other_complex_at)
      Atmosphere::Endpoint.create(port_mapping_template: other_pmt, invocation_path: 'ip', name: 'new')
    end

    it 'does not update appliance metadata when not published' do
      expect(MetadataRepositoryClient.instance).not_to receive(:update_appliance_type)
      endp41.destroy
    end
  end
end