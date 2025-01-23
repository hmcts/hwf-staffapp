class ChangeOver61NameInSavings < ActiveRecord::Migration[7.1]
  def change
    rename_column :savings, :over_61, :over_66
  end
end
