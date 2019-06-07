class AllowNullIncomeColumnsForOnlineApplication < ActiveRecord::Migration[5.2]
  def change
    change_column_null :online_applications, :children, true
  end
end
