class AddMissingBusinessEntities < ActiveRecord::Migration
  def up
    UpdateMissingBusinessEntities.up!
  end
end
