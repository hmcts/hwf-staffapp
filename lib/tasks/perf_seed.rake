require Rails.root.join('lib/perf/search_seeder')

namespace :perf do
  desc 'Seed PERF-tagged applications + applicants for search benchmarking. Args: count, batch.'
  task :seed_search, [:count, :batch] => :environment do |_t, args|
    abort("Refusing to seed in #{Rails.env}") unless Rails.env.development?
    target = (args[:count] || ENV['PERF_COUNT'] || 1_000_000).to_i
    batch  = (args[:batch] || ENV['PERF_BATCH'] || 100_000).to_i
    Perf::SearchSeeder.new(target: target, batch: batch).call
  end

  desc 'Remove all PERF-* tagged seed data (applicants then applications).'
  task clear_search: :environment do
    abort("Refusing to clear in #{Rails.env}") unless Rails.env.development?
    conn = ActiveRecord::Base.connection
    deleted_ants = conn.execute(<<~SQL.squish).cmd_tuples
      DELETE FROM applicants
      WHERE application_id IN (
        SELECT id FROM applications WHERE reference LIKE 'PERF-%'
      )
    SQL
    deleted_apps = conn.execute(
      "DELETE FROM applications WHERE reference LIKE 'PERF-%'"
    ).cmd_tuples
    puts "[perf:clear] removed #{deleted_ants} applicants, #{deleted_apps} applications"
  end

  desc 'Show current PERF-tagged row counts.'
  task seed_status: :environment do
    conn = ActiveRecord::Base.connection
    apps = conn.select_value("SELECT COUNT(*) FROM applications WHERE reference LIKE 'PERF-%'").to_i
    ants = conn.select_value(<<~SQL.squish).to_i
      SELECT COUNT(*) FROM applicants ap
      JOIN applications a ON a.id = ap.application_id
      WHERE a.reference LIKE 'PERF-%'
    SQL
    puts "[perf:status] PERF applications: #{apps}, PERF applicants: #{ants}"
  end
end
