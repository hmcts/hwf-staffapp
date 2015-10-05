class AddExpiresAtToSpotcheck < ActiveRecord::Migration
  def up
    add_column :spotchecks, :expires_at, :datetime

    EvidenceCheck.all.each do |spotcheck|
      expires_at = spotcheck.created_at + Settings.spotcheck.expires_in_days.days
      spotcheck.update(expires_at: expires_at)
    end

    change_column_null :spotchecks, :expires_at, false
  end

  def down
    remove_column :spotchecks, :expires_at
  end
end
