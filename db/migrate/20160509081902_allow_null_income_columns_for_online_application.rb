class AllowNullIncomeColumnsForOnlineApplication < ActiveRecord::Migration
  def change
    change_column_null :online_applications, :children, true
  end
end
