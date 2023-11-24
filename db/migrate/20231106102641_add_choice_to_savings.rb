class AddChoiceToSavings < ActiveRecord::Migration[7.0]
  def change
    add_column :savings, :choice, :string
  end
end
