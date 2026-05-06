module Perf
  # Compares the current name-search SQL (from SearchQueryBuilder) against
  # the proposed EXISTS+LIMIT rewrite, on the local DB. Reports best-of-N
  # wall-clock, full EXPLAIN ANALYZE, and an equivalence check on the
  # untrimmed result set.
  # rubocop:disable Metrics/ClassLength
  class SearchBenchmarker
    DEFAULT_LIMIT = 25

    def initialize(term:, office_id:, iterations: 3, logger: $stdout)
      @term = term
      @office_id = office_id.to_i
      @iterations = iterations.to_i
      @logger = logger
    end

    def call
      print_header
      verify_equivalence
      print_bench
      print_explains
    end

    private

    def print_header
      log '=' * 70
      log "perf:bench_search  term=#{@term.inspect}  office_id=#{@office_id}  iters=#{@iterations}"
      log "  applicants total: #{applicants_total}"
      log "  trigram indexes on applicants: #{trigram_present? ? 'PRESENT' : 'ABSENT'}"
      log '=' * 70
    end

    def verify_equivalence # rubocop:disable Metrics/AbcSize
      current = connection.select_values(current_sql_select_id).map(&:to_i).sort
      rewritten = connection.select_values(rewritten_sql_select_id).map(&:to_i).sort
      if current == rewritten
        log "Equivalence (no LIMIT): PASS — both return #{current.size} rows"
      else
        log "Equivalence: FAIL  current=#{current.size}  rewritten=#{rewritten.size}"
        log "  in current only:   #{(current - rewritten).first(5)}"
        log "  in rewritten only: #{(rewritten - current).first(5)}"
      end
      log ''
    end

    def print_bench # rubocop:disable Metrics/AbcSize
      cur_ms = bench_min_ms(current_sql_select_star)
      rew_ms = bench_min_ms(rewritten_sql_select_star(limit: DEFAULT_LIMIT))
      cur_rows = connection.execute(current_sql_select_star).ntuples
      rew_rows = connection.execute(rewritten_sql_select_star(limit: DEFAULT_LIMIT)).ntuples

      log format('  current SQL    : %7.1f ms  (rows: %d)', cur_ms, cur_rows)
      log format('  rewritten SQL  : %7.1f ms  (rows: %d, LIMIT %d)', rew_ms, rew_rows, DEFAULT_LIMIT)
      log format('  speedup        : %6.2fx', cur_ms / rew_ms) if rew_ms.positive?
      log ''
    end

    def print_explains
      log '--- EXPLAIN (ANALYZE, BUFFERS): current SQL ---'
      log explain_text(current_sql_select_star)
      log ''
      log "--- EXPLAIN (ANALYZE, BUFFERS): rewritten SQL (LIMIT #{DEFAULT_LIMIT}) ---"
      log explain_text(rewritten_sql_select_star(limit: DEFAULT_LIMIT))
    end

    def bench_min_ms(sql)
      connection.execute(sql) # warm-up
      timings = Array.new(@iterations) do
        t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        connection.execute(sql)
        (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000
      end
      timings.min
    end

    def explain_text(sql)
      connection.exec_query("EXPLAIN (ANALYZE, BUFFERS) #{sql}").rows.flatten.join("\n")
    end

    # rubocop:disable Metrics/MethodLength
    def current_sql_select_star
      term_q = quote("%#{@term}%")
      <<~SQL.squish
        SELECT DISTINCT applications.*
        FROM applications
        INNER JOIN applicants ON applicants.application_id = applications.id
        WHERE (
          applicants.first_name ILIKE #{term_q}
          OR applicants.last_name ILIKE #{term_q}
          OR CONCAT(applicants.first_name, ' ', applicants.last_name) ILIKE #{term_q}
        )
        AND applications.state != 0
        AND applications.office_id = #{@office_id}
        AND (applications.purged IS NULL OR applications.purged = FALSE)
        ORDER BY applications.created_at DESC
      SQL
    end

    def current_sql_select_id
      term_q = quote("%#{@term}%")
      <<~SQL.squish
        SELECT DISTINCT applications.id
        FROM applications
        INNER JOIN applicants ON applicants.application_id = applications.id
        WHERE (
          applicants.first_name ILIKE #{term_q}
          OR applicants.last_name ILIKE #{term_q}
          OR CONCAT(applicants.first_name, ' ', applicants.last_name) ILIKE #{term_q}
        )
        AND applications.state != 0
        AND applications.office_id = #{@office_id}
        AND (applications.purged IS NULL OR applications.purged = FALSE)
      SQL
    end

    def rewritten_sql_select_star(limit: nil)
      term_q = quote("%#{@term}%")
      limit_clause = limit ? "LIMIT #{limit.to_i}" : ''
      <<~SQL.squish
        SELECT applications.*
        FROM applications
        WHERE applications.office_id = #{@office_id}
          AND applications.state <> 0
          AND COALESCE(applications.purged, false) = false
          AND EXISTS (
            SELECT 1 FROM applicants
            WHERE applicants.application_id = applications.id
              AND (
                applicants.first_name ILIKE #{term_q}
                OR applicants.last_name ILIKE #{term_q}
                OR (applicants.first_name || ' ' || applicants.last_name) ILIKE #{term_q}
              )
          )
        ORDER BY applications.created_at DESC
        #{limit_clause}
      SQL
    end

    def rewritten_sql_select_id
      term_q = quote("%#{@term}%")
      <<~SQL.squish
        SELECT applications.id
        FROM applications
        WHERE applications.office_id = #{@office_id}
          AND applications.state <> 0
          AND COALESCE(applications.purged, false) = false
          AND EXISTS (
            SELECT 1 FROM applicants
            WHERE applicants.application_id = applications.id
              AND (
                applicants.first_name ILIKE #{term_q}
                OR applicants.last_name ILIKE #{term_q}
                OR (applicants.first_name || ' ' || applicants.last_name) ILIKE #{term_q}
              )
          )
      SQL
    end
    # rubocop:enable Metrics/MethodLength

    def trigram_present?
      sql = <<~SQL.squish
        SELECT COUNT(*) FROM pg_indexes
        WHERE tablename = 'applicants' AND indexdef ILIKE '%gin_trgm_ops%'
      SQL
      connection.select_value(sql).to_i.positive?
    end

    def applicants_total
      connection.select_value('SELECT COUNT(*) FROM applicants').to_i
    end

    def quote(value)
      connection.quote(value)
    end

    def connection
      ActiveRecord::Base.connection
    end

    def log(msg)
      @logger.puts(msg)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
