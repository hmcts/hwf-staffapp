class AddFullNameTrgmIndexToApplicants < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    execute <<~SQL.squish
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_applicants_on_full_name_trgm
      ON applicants USING gin ((first_name || ' ' || last_name) gin_trgm_ops);
    SQL
  end

  def down
    execute <<~SQL.squish
      DROP INDEX CONCURRENTLY IF EXISTS index_applicants_on_full_name_trgm;
    SQL
  end
end
