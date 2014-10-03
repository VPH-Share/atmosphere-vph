# This migration comes from atmosphere (originally 20140203135532)
class AddWranglerConfigToComputeSites < ActiveRecord::Migration
  def change
    add_column :compute_sites, :wrangler_url, :string
    add_column :compute_sites, :wrangler_username, :string
    add_column :compute_sites, :wrangler_password, :string
  end
end
