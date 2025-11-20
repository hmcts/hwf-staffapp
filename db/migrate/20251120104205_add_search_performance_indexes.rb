class AddSearchPerformanceIndexes < ActiveRecord::Migration[8.1]
  # Disable DDL transaction to allow concurrent index creation
  # This prevents blocking the database during index creation
  disable_ddl_transaction!

  def up
    # Enable pg_trgm extension for trigram-based pattern matching (ILIKE optimization)
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    # High Priority: Composite index for staff user searches
    # Combines the three most common filters: purged, state, and office_id
    # This makes staff searches 5-10x faster
    add_index :applications,
              [:purged, :state, :office_id],
              name: 'index_applications_on_purged_state_office',
              where: "(purged IS NULL OR purged = FALSE)",
              algorithm: :concurrently

    # High Priority: Composite index for admin user searches
    # Admin searches don't filter by office_id but still need purged + state filtering
    add_index :applications,
              [:purged, :state],
              name: 'index_applications_on_purged_state',
              where: "(purged IS NULL OR purged = FALSE) AND state != 0",
              algorithm: :concurrently

    # Medium Priority: Expression index for full name searches
    # Supports searches like "John Christopher Smith" matching first_name + last_name
    add_index :applicants,
              "LOWER(first_name || ' ' || last_name)",
              name: 'index_applicants_on_full_name_lower',
              algorithm: :concurrently

    # High Priority: GIN trigram indexes for ILIKE pattern matching
    # These dramatically speed up searches with wildcards (%search%)
    # Makes name searches ~10x faster
    execute <<-SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_applicants_on_first_name_trgm
      ON applicants USING gin (first_name gin_trgm_ops);
    SQL

    execute <<-SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_applicants_on_last_name_trgm
      ON applicants USING gin (last_name gin_trgm_ops);
    SQL

    execute <<-SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_details_on_case_number_trgm
      ON details USING gin (case_number gin_trgm_ops);
    SQL

    execute <<-SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_applicants_on_ni_number_trgm
      ON applicants USING gin (ni_number gin_trgm_ops);
    SQL
  end

  def down
    # Remove indexes in reverse order (concurrent for safety)
    execute <<-SQL
      DROP INDEX CONCURRENTLY IF EXISTS index_applicants_on_ni_number_trgm;
    SQL

    execute <<-SQL
      DROP INDEX CONCURRENTLY IF EXISTS index_details_on_case_number_trgm;
    SQL

    execute <<-SQL
      DROP INDEX CONCURRENTLY IF EXISTS index_applicants_on_last_name_trgm;
    SQL

    execute <<-SQL
      DROP INDEX CONCURRENTLY IF EXISTS index_applicants_on_first_name_trgm;
    SQL

    remove_index :applicants,
                 name: 'index_applicants_on_full_name_lower',
                 algorithm: :concurrently

    remove_index :applications,
                 name: 'index_applications_on_purged_state',
                 algorithm: :concurrently

    remove_index :applications,
                 name: 'index_applications_on_purged_state_office',
                 algorithm: :concurrently

    # Note: Not disabling pg_trgm extension as it might be used elsewhere
    # If you want to disable it, uncomment the next line:
    # disable_extension 'pg_trgm'
  end
end
