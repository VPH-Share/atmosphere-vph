class CreateSecurityProxies < ActiveRecord::Migration
  def change
    create_table :security_proxies do |t|
      t.string :name
      t.text :payload

      t.timestamps
    end

    create_table :security_proxies_users do |t|
      t.belongs_to :user
      t.belongs_to :security_proxy
    end

    change_table :appliance_types do |t|
      t.references :security_proxy, null: true
    end

    change_table :dev_mode_property_sets do |t|
      t.references :security_proxy, null: true
    end

    add_index :security_proxies, :name, unique: true

    add_foreign_key :appliance_types, :security_proxies
    add_foreign_key :dev_mode_property_sets, :security_proxies
  end
end
