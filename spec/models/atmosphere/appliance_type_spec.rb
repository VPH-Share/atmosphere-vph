require 'rails_helper'

describe Atmosphere::ApplianceType do
  it { should belong_to :security_proxy }

  describe '#create_from' do
    it 'set security proxy' do
      sp = create(:security_proxy)
      dev_set = create(:dev_appliance_set)
      at = create(:appliance_type)
      appl = create(:appliance, appliance_type: at, appliance_set: dev_set)
      appl.dev_mode_property_set.security_proxy = sp

      at = Atmosphere::ApplianceType.create_from(appl)

      expect(at.security_proxy).to eq(appl.dev_mode_property_set.security_proxy)
    end
  end

  describe 'as_metadata_xml' do
    let(:at) { create(:appliance_type) }
    let(:devel_at) { create(:appliance_type, visible_to: 'developer') }
    let(:evil_at) { create(:appliance_type, name: '</name></AtomicService>WE RULE!') }
    let(:user) { create(:user) }
    let(:owned_at) { create(:appliance_type, author: user) }
    let(:published_at) { create(:appliance_type, metadata_global_id: 'MDGLID') }
    let(:endp11) { build(:endpoint) }
    let(:endp12) { build(:endpoint, description: 'ENDP_DESC') }
    let(:endp21) { build(:endpoint) }
    let(:pmt1) { build(:port_mapping_template, endpoints: [endp11, endp12]) }
    let(:pmt2) { build(:port_mapping_template, endpoints: [endp21]) }
    let(:pmt3) { build(:port_mapping_template) }
    let(:complex_at) { create(:appliance_type, port_mapping_templates: [pmt1, pmt2, pmt3], description: 'DESC') }

    it 'creates minimal valid metadata xml document' do
      xml = at.as_metadata_xml.strip
      sleep 1
      expect(xml).to start_with('<resource_metadata>')
      expect(xml).to include('<atomicService>')
      expect(xml).to include('<name>'+at.name+'</name>')
      expect(xml).to include('<localID>'+at.id.to_s+'</localID>')
      expect(xml).to include('<author></author>')
      expect(xml).to include('<development>false</development>')
      expect(xml).to include('<description></description>')
      expect(xml).to include('<type>AtomicService</type>')
      expect(xml).to include('<category>None</category>')
      expect(xml).to include('<metadataUpdateDate>')
      expect(xml).to include('<metadataCreationDate>')
      update_time = Time.parse(xml.scan(/<metadataUpdateDate>(.*)<\/metadataUpdateDate>/).first.first)
      creation_time = Time.parse(xml.scan(/<metadataCreationDate>(.*)<\/metadataCreationDate>/).first.first)
      expect(update_time).to be_within(10.seconds).of(Time.now)
      expect(creation_time).to be_within(10.seconds).of(Time.now)
      expect(xml).to include('<creationDate>'+at.created_at.strftime('%Y-%m-%d %H:%M:%S')+'</creationDate>')
      expect(xml).to include('<updateDate>'+at.updated_at.strftime('%Y-%m-%d %H:%M:%S')+'</updateDate>')
      expect(xml).to include('</atomicService>')
      expect(xml).to end_with('</resource_metadata>')
    end

    it 'assigns correct user login' do
      xml = owned_at.as_metadata_xml.strip
      expect(xml).to include('<author>'+user.login+'</author>')
    end

    it 'creates proper update metadata xml document' do
      xml = published_at.as_metadata_xml.strip
      expect(xml).to include('<globalID>MDGLID</globalID>')
      expect(xml).to_not include('metadataCreationDate')
      expect(xml).to_not include('category')
    end

    it 'puts development state in metadata xml document' do
      xml = devel_at.as_metadata_xml.strip
      expect(xml).to include('<development>true</development>')
    end

    it 'handles endpoints properly' do
      xml = complex_at.as_metadata_xml.strip
      expect(xml).to include('<description>DESC</description>')
      expect(xml).to include('<endpoint>')
      expect(xml.scan('<endpoint>').size).to eq 3
      [endp11, endp12, endp21].each do |endp|
        expect(
          xml.split('Endpoint').any? do |endp_xml|
            if endp_xml.include? endp.name
              expect(endp_xml).to include('<endpointID>'+endp.id.to_s+'</endpointID>')
              expect(endp_xml).to include('<name>'+endp.name+'</name>')
              expect(endp_xml).to include('<description>'+endp.description.to_s+'</description>')
              true
            else
              false
            end
          end).to eq true
      end
    end

    it 'escapes XML content for proper document structure' do
      xml = evil_at.as_metadata_xml.strip
      expect(xml).to include('<name>&lt;/name&gt;&lt;/AtomicService&gt;WE RULE!</name>')
    end
  end

  describe 'manage metadata' do
    let(:at) { create(:appliance_type) }
    let(:public_at) { create(:appliance_type, visible_to: :all) }
    let(:devel_at) { create(:appliance_type, visible_to: :developer) }
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:published_at) { create(:appliance_type, visible_to: :all, metadata_global_id: 'mgid', preference_memory: 500, author: user) }
    let(:published_devel_at) { create(:appliance_type, visible_to: :developer, metadata_global_id: 'mgid') }

    it 'does not publish private appliance types' do
      expect(at).not_to receive(:publish_metadata)
      at.run_callbacks(:create)
    end

    it 'publishes new pubic appliance type' do
      expect(public_at).to receive(:publish_metadata)
      public_at.run_callbacks(:create)
    end

    it 'publishes new development appliance type' do
      expect(devel_at).to receive(:publish_metadata)
      devel_at.run_callbacks(:create)
    end

    it 'publishes private appliance type made public' do
      expect(public_at).to receive(:publish_metadata)
      public_at.save

      at.visible_to = :all
      mrc = MetadataRepositoryClient.instance
      expect(mrc).to receive(:publish_appliance_type).with(at)
      at.save
    end

    it 'publishes private appliance type made development' do
      at.visible_to = :developer
      mrc = MetadataRepositoryClient.instance
      expect(mrc).to receive(:publish_appliance_type).with(at)
      at.save
    end

    it 'does not publish private updated appliance type' do
      expect(at).to receive(:manage_metadata).once
      expect(at).not_to receive(:publish_metadata)
      at.run_callbacks(:update)
    end

    it 'does not unregister private or unpublished destroyed appliance type metadata' do
      expect(at).not_to receive(:remove_metadata)
      published_at.run_callbacks(:destroy)
      expect(public_at).not_to receive(:remove_metadata)
      public_at.run_callbacks(:destroy)
    end

    it 'unregisters published destroyed appliance type metadata' do
      expect(published_at).to receive(:remove_metadata).once
      published_at.run_callbacks(:destroy)

      expect(published_devel_at).to receive(:remove_metadata).once
      published_devel_at.run_callbacks(:destroy)
    end

    it 'does not try to update appliance type about to be destroyed' do
      expect{published_at.destroy}.not_to raise_exception
    end

    it 'updates metadata of published appliance type' do
      expect(published_at).to receive(:update_metadata).twice
      published_at.description = 'sth else'
      published_at.save
      published_at.name = 'new name'
      published_at.save
      expect(published_at).to receive(:update_metadata).once
      published_at.visible_to = :all # No real change here
      published_at.save
      published_at.visible_to = :developer
      published_at.save
    end

    it 'unregisters published appliance type made private' do
      expect(published_at).to receive(:remove_metadata).once
      published_at.visible_to = :owner
      published_at.save
    end

    it 'sets published appliance type made private mgid to nil' do
      expect(published_at.metadata_global_id).to eq 'mgid'
      published_at.visible_to = :owner
      published_at.save
      expect(published_at.metadata_global_id).to eq nil
    end

    it 'updates user login metadata on author change' do
      expect(published_at).to receive(:update_metadata).once
      published_at.author = other_user
      published_at.save
    end

    it 'updates user login metadata on author login change' do
      allow(user).to receive(:appliance_types).and_return([published_at])
      expect(published_at).to receive(:update_metadata).once
      user.login = 'Mr. Cellophane'
      user.save
    end

    it 'does not update metadata of published appliance type when no metadata change occurred' do
      expect(published_at).not_to receive(:update_metadata)
      published_at.preference_memory = 600
      published_at.save
    end
  end
end