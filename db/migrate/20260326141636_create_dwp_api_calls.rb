class CreateDwpApiCalls < ActiveRecord::Migration[8.1]
  def change
    create_table :dwp_api_calls do |t|
      t.references :benefit_check, null: false, foreign_key: true
      t.string :endpoint_name
      t.integer :response_status
      t.jsonb :request_params
      t.jsonb :data

      t.timestamps
    end
  end
end
