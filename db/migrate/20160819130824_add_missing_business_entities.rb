class AddMissingBusinessEntities < ActiveRecord::Migration[5.2]
  def up
    UpdateMissingBusinessEntities.up!
  end
end
