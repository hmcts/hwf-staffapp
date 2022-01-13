class CreateTableHmrcCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :hmrc_calls, id: :uuid do |t|
      t.string :call_params
      t.integer :hrmc_check_id, null: false
      t.string :endpoint_name
      t.timestamps
    end
  end
end
