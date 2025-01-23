class ChangeOver61Name < ActiveRecord::Migration[7.1]
  def change
    rename_column :online_applications, :over_61, :over_66
  end
end
