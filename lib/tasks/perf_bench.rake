require Rails.root.join('lib/perf/search_benchmarker')

namespace :perf do
  desc 'Benchmark current vs rewritten name-search SQL. Args: term, office_id, iterations.'
  task :bench_search, [:term, :office_id, :iterations] => :environment do |_t, args|
    abort("Refusing to bench in #{Rails.env}") unless Rails.env.development?
    term = (args[:term] || 'smith').to_s
    office = (args[:office_id] || 1).to_i
    iters = (args[:iterations] || 3).to_i
    Perf::SearchBenchmarker.new(term: term, office_id: office, iterations: iters).call
  end

  desc 'Benchmark a default suite of search terms (smith, patel, oli, "john smith"). Args: office_id, iterations.'
  task :bench_search_suite, [:office_id, :iterations] => :environment do |_t, args|
    abort("Refusing to bench in #{Rails.env}") unless Rails.env.development?
    office = (args[:office_id] || 1).to_i
    iters = (args[:iterations] || 3).to_i
    ['smith', 'patel', 'oli', 'john smith'].each do |term|
      Perf::SearchBenchmarker.new(term: term, office_id: office, iterations: iters).call
      puts "\n"
    end
  end

  desc 'Drop the GIN trigram indexes on applicants (first_name, last_name, ni_number) to reproduce prod baseline.'
  task drop_trgm: :environment do
    abort("Refusing to drop in #{Rails.env}") unless Rails.env.development?
    conn = ActiveRecord::Base.connection
    [
      'index_applicants_on_first_name_trgm',
      'index_applicants_on_last_name_trgm',
      'index_applicants_on_ni_number_trgm'
    ].each do |idx|
      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      conn.execute("DROP INDEX IF EXISTS #{idx}")
      elapsed = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0).round(2)
      puts "[perf:drop_trgm] dropped #{idx} (#{elapsed}s)"
    end
  end

  desc 'Recreate the GIN trigram indexes on applicants. Slow on large datasets.'
  task create_trgm: :environment do
    abort("Refusing to create in #{Rails.env}") unless Rails.env.development?
    conn = ActiveRecord::Base.connection
    {
      'index_applicants_on_first_name_trgm' => 'first_name',
      'index_applicants_on_last_name_trgm' => 'last_name',
      'index_applicants_on_ni_number_trgm' => 'ni_number'
    }.each do |idx, col|
      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      conn.execute(
        "CREATE INDEX IF NOT EXISTS #{idx} ON applicants USING gin (#{col} gin_trgm_ops)"
      )
      elapsed = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0).round(2)
      puts "[perf:create_trgm] created #{idx} (#{elapsed}s)"
    end
  end
end
