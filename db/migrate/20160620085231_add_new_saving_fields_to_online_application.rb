class AddNewSavingFieldsToOnlineApplication < ActiveRecord::Migration
  def change
    rename_column :online_applications, :threshold_exceeded, :min_threshold_exceeded
    add_column :online_applications, :max_threshold_exceeded, :boolean
    add_column :online_applications, :over_61, :boolean
    add_column :online_applications, :amount, :integer

    reversible do |dir|
      dir.up do
        migrate_sql = <<~SQL
          UPDATE online_applications
          SET max_threshold_exceeded = min_threshold_exceeded
        SQL
        execute(migrate_sql)
      end
    end
  end
end
