class AddIncomePeriodToOnlineApplicaiton < ActiveRecord::Migration[7.0]
  def change
    add_column :online_applications, :income_period, :string
  end
end
