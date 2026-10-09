module Views
  module Reports
    # RST-7882: the six DWP benefit check columns shared by the raw data and
    # applications-by-court exports, read from the latest benefit check.
    # 'LAA' marks a check made through the old checker (nil checker), 'N/A' a
    # row the columns do not apply to or whose check did not answer. See CHANGELOG.md
    module BenefitCheckColumns
      private

      # not_applicable: SQL that is true when the row gets 'N/A' in every column;
      # the latest check must be joined as "bc".
      def benefit_check_columns(not_applicable)
        <<~SQL.squish
          CASE WHEN #{not_applicable} THEN 'N/A'
               WHEN #{laa_check} THEN 'LAA'
               WHEN bc.dwp_result IN ('Yes', 'No') THEN bc.dwp_result
               ELSE 'N/A' END AS benefit_checker_response,
          #{benefit_check_column('bc.error_message', not_applicable)} AS benefit_checker_errors,
          #{benefit_check_column("to_char(bc.date_of_death, 'YYYY-MM-DD')", not_applicable)} AS date_of_death,
          #{benefit_check_column('bc.benefit_types', not_applicable)} AS benefit_type,
          #{benefit_check_column('bc.claim_status', not_applicable)} AS benefit_status,
          #{benefit_check_column('bc.take_home_pay::text', not_applicable)} AS take_home_pay,
        SQL
      end

      # 'N/A' for an empty value too, so every export shows the same thing
      def benefit_check_column(value, not_applicable)
        "CASE WHEN #{not_applicable} THEN 'N/A' WHEN #{laa_check} THEN 'LAA' ELSE COALESCE(#{value}, 'N/A') END"
      end

      def laa_check
        "bc.checker IS NULL OR bc.checker = 'laa'"
      end

      # The latest check per paper application, whether it was made on the
      # application or on the online application it came from. Join on app_id.
      def latest_benefit_check_per_application_sql
        <<~SQL.squish
          SELECT checks.*, row_number() OVER (PARTITION BY checks.app_id ORDER BY checks.created_at DESC, checks.id DESC) AS row_number
          FROM (
            SELECT benefit_checks.*, applications.id AS app_id
            FROM benefit_checks
            INNER JOIN applications ON (benefit_checks.applicationable_type = 'Application' AND benefit_checks.applicationable_id = applications.id)
              OR (benefit_checks.applicationable_type = 'OnlineApplication' AND benefit_checks.applicationable_id = applications.online_application_id)
            WHERE benefit_checks.dwp_result IS NOT NULL
          ) checks
        SQL
      end

      # The latest check on one record (an online application not yet converted). Join on type and id.
      def latest_benefit_check_per_record_sql
        <<~SQL.squish
          SELECT benefit_checks.*,
                 row_number() OVER (PARTITION BY applicationable_type, applicationable_id ORDER BY created_at DESC, id DESC) AS row_number
          FROM benefit_checks
          WHERE dwp_result IS NOT NULL
        SQL
      end
    end
  end
end
