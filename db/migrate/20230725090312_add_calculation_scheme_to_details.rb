class AddCalculationSchemeToDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :details, :calculation_scheme, :string
  end
end
