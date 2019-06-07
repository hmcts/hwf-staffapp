class AddOnlineApplicationReferenceToApplication < ActiveRecord::Migration[5.2]
  def change
    add_reference :applications, :online_application, null: true, index: true, foreign_key: { on_update: :cascade }
  end
end
