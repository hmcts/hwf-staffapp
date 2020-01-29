class RenameCcmccCheckTypeColumn < ActiveRecord::Migration[5.2]
  def up
    rename_column :evidence_checks, :ccmcc_check_type, :ccmcc_annotation
  end

  def down
    rename_column :evidence_checks, :ccmcc_annotation, :ccmcc_check_type
  end
end
