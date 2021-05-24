class CreateHmrcTokenTable < ActiveRecord::Migration[6.0]
  def change
    create_table :hmrc_tokens do |t|
      t.string :encrypted_access_token
      t.datetime :expires_in

      t.timestamps
    end
  end
end
