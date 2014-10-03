# This migration comes from atmosphere (originally 20140304162004)
class AddZabbixHostIdToVirtualMachines < ActiveRecord::Migration
  def change
    add_column :virtual_machines, :zabbix_host_id, :integer
  end
end
