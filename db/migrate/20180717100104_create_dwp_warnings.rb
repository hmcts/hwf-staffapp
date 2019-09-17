class CreateDwpWarnings < ActiveRecord::Migration[5.2]
  def change
    create_table :dwp_warnings do |t|
      t.string :check_state, default: 'default_checker'

      t.timestamps null: false
    end
  end
end
