class AddIncomeKindToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :income_kind, :string
  end
end
