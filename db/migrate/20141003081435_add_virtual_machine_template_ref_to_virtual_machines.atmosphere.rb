# This migration comes from atmosphere (originally 20130821152426)
class AddVirtualMachineTemplateRefToVirtualMachines < ActiveRecord::Migration
  def change
    add_reference :virtual_machines, :virtual_machine_template, index: true
    add_foreign_key :virtual_machines, :virtual_machine_templates
  end
end
