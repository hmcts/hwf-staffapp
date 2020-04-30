class AddIncomeKindToOnlineApplicationTable < ActiveRecord::Migration[5.2]
  def change
    add_column :online_applications, :income_kind, :string
  end
end
