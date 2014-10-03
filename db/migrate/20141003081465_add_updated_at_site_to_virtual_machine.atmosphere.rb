# This migration comes from atmosphere (originally 20140611055320)
class AddUpdatedAtSiteToVirtualMachine < ActiveRecord::Migration
  def change
    add_column :virtual_machines, :updated_at_site, :datetime
  end
end
