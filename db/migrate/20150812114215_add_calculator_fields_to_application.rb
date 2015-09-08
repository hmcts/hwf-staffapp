class AddCalculatorFieldsToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :application_type, :string
    add_column :applications, :application_outcome, :string
    add_column :applications, :amount_to_pay, :integer
  end
end
