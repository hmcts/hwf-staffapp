class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :application, index: true, null: false
      t.datetime :expires_at, null: false

      t.timestamps null: false
    end
  end
end
