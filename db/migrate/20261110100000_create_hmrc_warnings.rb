class CreateHmrcWarnings < ActiveRecord::Migration[8.1]
  def change
    create_table :hmrc_warnings do |t|
      t.string :check_state, default: 'default_checker'
      t.timestamps
    end
  end
end
