class AddFeeCodeAndClaimAmountToDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :details, :fee_code, :string
    add_column :details, :claim_amount, :decimal
  end
end
