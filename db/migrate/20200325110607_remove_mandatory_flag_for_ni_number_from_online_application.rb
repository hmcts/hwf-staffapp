class RemoveMandatoryFlagForNiNumberFromOnlineApplication < ActiveRecord::Migration[5.2]
  def up
    change_column_null :online_applications, :ni_number, :true
  end
end
