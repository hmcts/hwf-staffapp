class RenameCcmccAnnotationToChecksAnnotation < ActiveRecord::Migration[5.2]
  def up
    rename_column :evidence_checks, :ccmcc_annotation, :checks_annotation
  end

  def down
    rename_column :evidence_checks, :checks_annotation, :ccmcc_annotation
  end
end
