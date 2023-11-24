class AddStatementToDetail < ActiveRecord::Migration[7.0]
  def change
    add_column :details, :statement_signed_by, :string
  end
end
