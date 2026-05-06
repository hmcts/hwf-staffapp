module Perf
  # Bulk-loads synthetic applications + applicants (1:1) for benchmarking the
  # name-search query locally. Tags every row with reference = 'PERF-<padded>'
  # so the cleanup task can remove only seeded data.
  # rubocop:disable Metrics/ClassLength
  class SearchSeeder
    REFERENCE_PREFIX = 'PERF-'.freeze
    REFERENCE_PAD = 9
    DAYS_SPREAD = 730

    FIRST_NAMES = [
      'Oliver', 'George', 'Harry', 'Jack', 'Jacob', 'Noah', 'Charlie', 'Muhammad', 'Thomas', 'Oscar',
      'William', 'James', 'Henry', 'Leo', 'Alfie', 'Joshua', 'Freddie', 'Archie', 'Ethan', 'Isaac',
      'Alexander', 'Joseph', 'Edward', 'Samuel', 'Max', 'Daniel', 'Logan', 'Theo', 'Arthur', 'Lucas',
      'Olivia', 'Amelia', 'Isla', 'Ava', 'Mia', 'Isabella', 'Sophia', 'Lily', 'Grace', 'Evie',
      'Sophie', 'Poppy', 'Freya', 'Charlotte', 'Harper', 'Willow', 'Florence', 'Daisy', 'Phoebe', 'Erin'
    ].freeze

    LAST_NAMES = [
      'Smith', 'Jones', 'Williams', 'Brown', 'Taylor', 'Davies', 'Wilson', 'Evans', 'Thomas', 'Roberts',
      'Johnson', 'Walker', 'Wright', 'Robinson', 'Thompson', 'White', 'Hughes', 'Edwards', 'Green', 'Hall',
      'Wood', 'Harris', 'Lewis', 'Martin', 'Jackson', 'Clarke', 'Turner', 'Hill', 'Scott', 'Cooper',
      'Morris', 'Ward', 'Moore', 'King', 'Watson', 'Baker', 'Morgan', 'Patel', 'Khan', 'Singh',
      'Kumar', 'Shah', 'Begum', 'Hussain', 'Ahmed', 'Ali', 'Choudhury', 'Rahman', 'Murphy', 'OBrien'
    ].freeze

    def initialize(target:, batch: 100_000, logger: $stdout)
      @target = target
      @batch = batch
      @logger = logger
    end

    def call
      raise 'Refusing to run outside development' unless Rails.env.development?
      raise 'No offices found; cannot satisfy office_id FK' if office_ids.empty?

      log "Target: #{@target} PERF rows (batch #{@batch})"
      log "Using office IDs: #{office_ids.inspect}"

      seed_applications
      seed_applicants
      report_final
    end

    private

    def seed_applications # rubocop:disable Metrics/MethodLength
      already = perf_application_count
      if already >= @target
        log "Applications: already have #{already} PERF rows (>= target #{@target}); skipping"
        return
      end

      start_i = already + 1
      log "Applications: inserting #{start_i}..#{@target}"
      ((start_i)..(@target)).step(@batch) do |from|
        to = [from + @batch - 1, @target].min
        elapsed = time { insert_applications_batch(from, to) }
        log "  applications #{from}..#{to} inserted in #{elapsed}s"
      end
    end

    def seed_applicants # rubocop:disable Metrics/MethodLength
      missing = perf_applications_without_applicant_count
      if missing.zero?
        log 'Applicants: all PERF applications already have an applicant; skipping'
        return
      end

      log "Applicants: backfilling #{missing} rows"
      loop do
        elapsed = time { @inserted_in_pass = insert_applicants_batch }
        break if @inserted_in_pass.zero?
        log "  applicants +#{@inserted_in_pass} in #{elapsed}s"
      end
    end

    # rubocop:disable Metrics/MethodLength
    def insert_applications_batch(from, to)
      sql = <<~SQL.squish
        INSERT INTO applications (
          reference, office_id, state, purged, created_at, updated_at
        )
        SELECT
          '#{REFERENCE_PREFIX}' || lpad(s.i::text, #{REFERENCE_PAD}, '0'),
          (#{office_id_array})[((s.i - 1) % #{office_ids.size}) + 1],
          CASE
            WHEN (s.i % 100) <  10 THEN 0
            WHEN (s.i % 100) <  20 THEN 1
            WHEN (s.i % 100) <  25 THEN 2
            WHEN (s.i % 100) <  95 THEN 3
            ELSE 4
          END,
          CASE WHEN (s.i % 100) < 5 THEN NULL::boolean ELSE FALSE END,
          NOW() - (((s.i::bigint * 7919) % (#{DAYS_SPREAD} * 86400)) || ' seconds')::interval,
          NOW() - (((s.i::bigint * 7919) % (#{DAYS_SPREAD} * 86400)) || ' seconds')::interval
        FROM generate_series(#{from.to_i}, #{to.to_i}) AS s(i)
      SQL
      connection.execute(sql)
    end

    def insert_applicants_batch
      sql = <<~SQL.squish
        WITH candidates AS (
          SELECT a.id, a.created_at
          FROM applications a
          WHERE a.reference LIKE '#{REFERENCE_PREFIX}%'
            AND NOT EXISTS (SELECT 1 FROM applicants ap WHERE ap.application_id = a.id)
          ORDER BY a.id
          LIMIT #{@batch.to_i}
        )
        INSERT INTO applicants (
          application_id, first_name, last_name, ni_number,
          date_of_birth, created_at, updated_at
        )
        SELECT
          c.id,
          (#{first_name_array})[(c.id % #{FIRST_NAMES.size}) + 1],
          (#{last_name_array})[((c.id / #{FIRST_NAMES.size}) % #{LAST_NAMES.size}) + 1],
          'AB' || lpad((c.id % 1000000)::text, 6, '0') || (c.id % 10)::text || 'C',
          (CURRENT_DATE - (((c.id % 60) + 18) || ' years')::interval)::date,
          c.created_at,
          c.created_at
        FROM candidates c
      SQL
      connection.execute(sql).cmd_tuples
    end
    # rubocop:enable Metrics/MethodLength

    def perf_application_count
      connection.select_value(
        "SELECT COUNT(*) FROM applications WHERE reference LIKE '#{REFERENCE_PREFIX}%'"
      ).to_i
    end

    def perf_applications_without_applicant_count
      connection.select_value(<<~SQL.squish).to_i
        SELECT COUNT(*) FROM applications a
        WHERE a.reference LIKE '#{REFERENCE_PREFIX}%'
          AND NOT EXISTS (SELECT 1 FROM applicants ap WHERE ap.application_id = a.id)
      SQL
    end

    def report_final
      apps = perf_application_count
      ants = connection.select_value(<<~SQL.squish).to_i
        SELECT COUNT(*) FROM applicants ap
        JOIN applications a ON a.id = ap.application_id
        WHERE a.reference LIKE '#{REFERENCE_PREFIX}%'
      SQL
      log "Done. PERF applications: #{apps}, PERF applicants: #{ants}"
    end

    def office_ids
      @office_ids ||= connection.select_values('SELECT id FROM offices ORDER BY id').map(&:to_i)
    end

    def office_id_array
      "ARRAY[#{office_ids.join(',')}]::int[]"
    end

    def first_name_array
      "ARRAY[#{FIRST_NAMES.map { |n| "'#{n}'" }.join(',')}]::varchar[]"
    end

    def last_name_array
      "ARRAY[#{LAST_NAMES.map { |n| "'#{n}'" }.join(',')}]::varchar[]"
    end

    def connection
      ActiveRecord::Base.connection
    end

    def time
      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0).round(2)
    end

    def log(msg)
      @logger.puts("[perf:seed] #{msg}")
    end
  end
  # rubocop:enable Metrics/ClassLength
end
