class AddOver16ToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :over_16, :boolean
  end
end
