# This migration comes from atmosphere (originally 20140204132451)
class NullifyAtVmtFk < ActiveRecord::Migration
  def change
    remove_foreign_key :virtual_machine_templates, :appliance_types
    add_foreign_key :virtual_machine_templates, :appliance_types, dependent: :nullify
  end
end
