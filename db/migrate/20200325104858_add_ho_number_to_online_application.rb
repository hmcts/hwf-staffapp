class AddHoNumberToOnlineApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :online_applications, :ho_number, :string
  end
end
