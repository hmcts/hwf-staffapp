class AddPurgedAtToHmrcChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :hmrc_checks, :purged_at, :datetime
  end
end
