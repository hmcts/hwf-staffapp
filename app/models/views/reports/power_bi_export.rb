module Views
  module Reports
    class PowerBiExport
      require 'csv'
      require 'zip'
      attr_reader :zipfile_path

      def initialize
        @csv_data = to_csv
        @zipfile_path = 'tmp/export.zip'
        generate_file
      end

      def tidy_up
        File.delete(zipfile_path)
      end

      private

      def generate_file
        csv_file_name = "#{Time.zone.today.to_s(:db)}-power-bi.csv"
        Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
          zipfile.get_output_stream(csv_file_name) { |f| f.write @csv_data }
        end
      end

      def to_csv
        CSV.generate do |csv|
          csv << data.first.keys
          data.each do |row|
            csv << row.values
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      def sql_query
        'SELECT
              a.id AS "application/id",
              CASE
                WHEN a.state = 0 THEN \'created\'
                WHEN a.state = 1 THEN \'waiting for evidence\'
                WHEN a.state = 2 THEN \'waiting for part payment\'
                WHEN a.state = 3 THEN \'processed\'
                WHEN a.state = 4 THEN \'deleted\'
              END AS "application/state",
            COALESCE(a.application_type, \'not processed\') AS "application_type",
              dca.dense_rank AS "application/created_at_sequence",
              TO_CHAR(a.created_at :: DATE, \'Mon-yyyy\') AS "application/created_at",
              a.office_id AS "application/office_id",
              COALESCE(a.outcome, \'not processed\') AS "application/outcome",
              a.decision_cost AS "application/decision_cost",
              a.medium AS "application/medium",
              d.id AS "details/id",
              d.application_id AS "details/application_id",
              CASE
                  WHEN d.refund IS TRUE THEN \'Retro\'
                  WHEN d.refund IS FALSE THEN \'On-issue\'
                  ELSE \'not processed\'
              END AS "details/refund",
              j.id AS "jurisdiction/id",
              COALESCE(j.name, \'not processed\') AS "jurisdiction/name",
              o.id AS "office/id",
              COALESCE(o.name, \'not processed\') AS "office/name"
          FROM applications a
          LEFT JOIN (
              SELECT
                  month_year,
                  dense_rank() over( ORDER BY parsed_month_year DESC)
              FROM (
                  SELECT
                  DISTINCT to_char(created_at,\'Mon-YYYY\') AS month_year,
                  TO_DATE(to_char(created_at,\'Mon-YYYY\'), \'Mon-yyyy\') AS parsed_month_year
                  FROM applications
                  WHERE created_at < date_trunc(\'MONTH\',now()) AND
                      created_at >= (date_trunc(\'MONTH\',now()) - INTERVAL \'25  months\')
              ) distinct_created_at
          ) dca ON dca.month_year = TO_CHAR(a.created_at :: DATE, \'Mon-yyyy\')
          LEFT JOIN details d ON d.application_id = a.id
          LEFT JOIN evidence_checks ec ON ec.application_id = a.id AND NOT EXISTS (
              SELECT 1 FROM evidence_checks ec1
              WHERE ec1.application_id = a.id
              AND ec1.id > ec.id
          )
          LEFT JOIN business_entities be ON be.id = a.business_entity_id
          LEFT JOIN jurisdictions j ON j.id = be.jurisdiction_id
          LEFT JOIN offices o ON o.id = be.office_id
          LEFT JOIN part_payments pp ON pp.application_id = a.id AND NOT EXISTS (
              SELECT 1 FROM part_payments pp1
              WHERE pp1.application_id = a.id
              AND pp1.id > pp.id
          )
          WHERE a.created_at < date_trunc(\'MONTH\',now()) AND
              a.created_at >= (date_trunc(\'MONTH\',now()) - INTERVAL \'12 months\')
          ORDER by a.created_at DESC'
      end
      # rubocop:enable Metrics/MethodLength

      def data
        @data ||= build_data
      end

      def build_data
        ActiveRecord::Base.connection.execute(sql_query)
      end

    end
  end
end
