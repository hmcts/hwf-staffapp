class AddHoNumberToApplicant < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :ho_number, :string
  end
end
