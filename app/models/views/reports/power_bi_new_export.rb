# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    # Power BI New Export - Unified export with three modes
    #
    # Usage from Rails console:
    #   export = Views::Reports::PowerBiNewExport.new('2024-01-01', '2025-02-01', verbose: true)
    #   export.export1  # processed only (by decision_date)
    #   export.export2  # all except 'created' (by created_at)
    #   export.export3  # waiting_for_evidence and waiting_for_part_payment only (by created_at)
    #
    class PowerBiNewExport
      require 'csv'
      require 'zip'

      attr_reader :zipfile_path

      HEADERS = [
        'id',
        'office',
        'jurisdiction',
        'fee',
        'estimated applicant pay',
        'estimated cost',
        'application type',
        'form',
        'refund',
        'pre evidence income',
        'post evidence income',
        'income period',
        'married',
        'pension age',
        'decision',
        'failed on savings',
        'final applicant pays',
        'departmental cost',
        'source',
        'benefits granted?',
        'evidence checked?',
        'savings and investments amount',
        'PP outcome',
        'low income declared',
        'date received',
        'decision date',
        'date paid',
        'application processed date',
        'manual evidence processed date',
        'date submitted online',
        'statement signed by',
        'DB evidence check type',
        'DB income check type',
        'HMRC total income',
        'evidence check outcome',
        'evidence check type',
        'HMRC response?',
        'HMRC errors',
        'complete processing?',
        'additional income',
        'income processed',
        'HMRC request date range'
      ].freeze

      EXCLUDED_OFFICES = "('Digital', 'HMCTS HQ Team')"

      def initialize(start_date, end_date, verbose: false)
        @date_from = parse_date(start_date)
        @date_to = parse_date(end_date).end_of_day
        @verbose = verbose
      end

      # Export 1: Processed applications only (by decision_date)
      def export1
        @export_type = :processed
        @date_field = 'decision_date'
        @state_filter = "= #{Application.states[:processed]}"
        @filter_description = "processed only"
        run_export('export1')
      end

      # Export 2: All states except 'created' (by created_at)
      def export2
        @export_type = :all_except_created
        @date_field = 'created_at'
        @state_filter = "!= #{Application.states[:created]}"
        @filter_description = "all states except 'created'"
        run_export('export2')
      end

      # Export 3: Waiting for evidence and waiting for part payment only (by created_at)
      def export3
        @export_type = :waiting_only
        @date_field = 'created_at'
        waiting_states = [
          Application.states[:waiting_for_evidence],
          Application.states[:waiting_for_part_payment]
        ].join(', ')
        @state_filter = "IN (#{waiting_states})"
        @filter_description = "waiting_for_evidence and waiting_for_part_payment only"
        run_export('export3')
      end

      def total_count
        @total_count ||= 0
      end

      private

      def run_export(export_name)
        setup_file_paths(export_name)
        log "Starting #{export_name} for #{@date_from.to_date} to #{@date_to.to_date}..."
        log "Filtering: #{@filter_description}"
        start_time = Time.current

        generate_csv
        zip_file

        log "Export completed in #{(Time.current - start_time).round(2)} seconds"
        log "Output: #{@zipfile_path}"
        @zipfile_path.to_s
      end

      def setup_file_paths(export_name)
        timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
        @csv_file_name = "power_bi_#{export_name}_#{timestamp}.csv"
        @csv_file_path = Rails.root.join('tmp', @csv_file_name)
        @zipfile_path = Rails.root.join('tmp', "#{@csv_file_name}.zip")
      end

      def parse_date(date_input)
        case date_input
        when Hash
          DateTime.parse(date_input.values.join('/')).utc
        when String
          DateTime.parse(date_input).utc
        when Date, DateTime, Time
          date_input.to_datetime.utc
        else
          raise ArgumentError, "Invalid date format: #{date_input.class}"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def generate_csv
        log "Generating CSV..."
        row_count = 0

        File.open(@csv_file_path, 'w') do |file|
          file.write(CSV.generate_line(HEADERS))

          fetch_data_in_batches do |rows|
            rows.each do |row|
              file.write(CSV.generate_line(build_csv_row(row)))
              row_count += 1
            end
            log "  Processed #{row_count} records..." if (row_count % 10_000).zero?
          end
        end

        @total_count = row_count
        log "  Total records: #{row_count}"
      end
      # rubocop:enable Metrics/MethodLength

      def fetch_data_in_batches(batch_size: 5000)
        offset = 0

        loop do
          sql = build_sql_query(limit: batch_size, offset: offset)
          rows = ActiveRecord::Base.connection.exec_query(sql).to_a

          break if rows.empty?

          yield rows.map(&:with_indifferent_access)

          break if rows.size < batch_size

          offset += batch_size
        end
      end

      # rubocop:disable Metrics/MethodLength
      def build_sql_query(limit:, offset:)
        <<~SQL.squish
          SELECT
            applications.id,
            offices.name AS office,
            jurisdictions.name AS jurisdiction,
            details.fee,
            COALESCE(applications.amount_to_pay, 0) AS amount_to_pay,
            applications.application_type,
            details.form_name AS form,
            details.refund,
            applications.income AS pre_evidence_income,
            ec.income AS post_evidence_income,
            applications.income_period,
            applicants.married,
            savings.over_66,
            applications.decision,
            CASE WHEN savings.passed = FALSE THEN 'Yes'
                 WHEN savings.passed = TRUE THEN 'No'
                 ELSE 'N/A' END AS saving_failed,
            ec.amount_to_pay AS ec_amount_to_pay,
            part_payments.outcome AS pp_outcome,
            applications.decision_cost,
            CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
            CASE WHEN beo.id IS NULL THEN 'N/A'
                 WHEN beo.correct = TRUE THEN 'Yes'
                 WHEN beo.correct = FALSE THEN 'No'
            END AS benefits_granted,
            CASE WHEN ec.id IS NULL THEN 'no' ELSE 'yes' END AS evidence_checked,
            CASE WHEN savings.amount >= 16000 THEN NULL
                 ELSE savings.amount
            END AS savings_amount,
            CASE WHEN applications.income <= 101 THEN 'true'
                 WHEN applications.income > 101 THEN 'false'
                 ELSE 'N/A' END AS low_income_declared,
            details.date_received,
            applications.decision_date,
            details.date_fee_paid,
            applications.completed_at AS application_processed_date,
            CASE WHEN ec.income_check_type = 'paper' THEN ec.completed_at ELSE NULL END AS manual_process_date,
            oa.created_at AS date_submitted_online,
            details.statement_signed_by,
            ec.check_type AS db_evidence_check_type,
            ec.income_check_type AS db_income_check_type,
            ec.hmrc_income_used AS hmrc_total_income,
            ec.outcome AS ev_check_outcome,
            CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL THEN 'Manual NumberRule'
                 WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL THEN 'Manual NIFlag'
                 WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL THEN 'Manual NIDuplicate'
                 WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL THEN 'Manual LowIncome'
                 WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' THEN 'HMRC NumberRule'
                 WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' THEN 'HMRC NIFlag'
                 WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' THEN 'HMRC NIDuplicate'
                 WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'hmrc' THEN 'HMRC LowIncome'
                 WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL THEN 'ManualAfterHMRC'
                 WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL THEN 'ManualAfterHMRC'
                 WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL THEN 'ManualAfterHMRC'
                 ELSE NULL
            END AS evidence_check_type,
            CASE WHEN hc.hc_id IS NULL THEN NULL
                 WHEN hc.hc_id IS NOT NULL AND hc.error_response IS NULL THEN 'Yes'
                 WHEN hc.hc_id IS NOT NULL AND hc.error_response IS NOT NULL THEN 'No'
                 ELSE NULL
            END AS hmrc_response,
            hc.error_response AS hmrc_errors,
            CASE WHEN hc.hc_id IS NULL THEN NULL
                 WHEN hc.hc_id IS NOT NULL AND ec.completed_at IS NOT NULL THEN 'Yes'
                 WHEN hc.hc_id IS NOT NULL AND ec.completed_at IS NULL THEN 'No'
                 ELSE NULL
            END AS complete_processing,
            CASE WHEN hc.additional_income IS NULL THEN NULL
                 WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'paper' THEN NULL
                 WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'hmrc'
                   AND hc.additional_income > 0 THEN hc.additional_income
                 ELSE NULL
            END AS additional_income,
            CASE WHEN ec.income IS NULL THEN applications.income
                 WHEN ec.completed_at IS NOT NULL THEN ec.income
                 ELSE NULL
            END AS income_processed,
            hc.request_params AS hmrc_request_date_range
          FROM applications
          INNER JOIN applicants ON applicants.application_id = applications.id
          INNER JOIN details ON details.application_id = applications.id
          INNER JOIN offices ON offices.id = applications.office_id
          LEFT JOIN jurisdictions ON jurisdictions.id = details.jurisdiction_id
          LEFT JOIN benefit_overrides beo ON beo.application_id = applications.id
          LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
          LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
          LEFT JOIN savings ON savings.application_id = applications.id
          LEFT JOIN part_payments ON part_payments.application_id = applications.id
          LEFT JOIN (
            SELECT id AS hc_id, request_params, additional_income, error_response, evidence_check_id,
                   ROW_NUMBER() OVER (PARTITION BY evidence_check_id ORDER BY created_at DESC) AS row_number
            FROM hmrc_checks
          ) hc ON ec.id = hc.evidence_check_id AND (hc.row_number = 1 OR hc.row_number IS NULL)
          WHERE offices.name NOT IN #{EXCLUDED_OFFICES}
            AND applications.#{@date_field} >= '#{@date_from.strftime('%Y-%m-%d %H:%M:%S')}'
            AND applications.#{@date_field} <= '#{@date_to.strftime('%Y-%m-%d %H:%M:%S')}'
            AND applications.state #{@state_filter}
          ORDER BY applications.id
          LIMIT #{limit} OFFSET #{offset}
        SQL
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def build_csv_row(row)
        [
          row['id'],
          row['office'],
          row['jurisdiction'],
          row['fee'],
          estimated_applicant_pay(row),
          estimated_cost(row),
          row['application_type'],
          row['form'] || 'N/A',
          row['refund'],
          row['pre_evidence_income'],
          row['post_evidence_income'],
          row['income_period'],
          row['married'],
          pension_age(row),
          row['decision'],
          row['saving_failed'],
          final_applicant_pays(row),
          row['decision_cost'],
          row['source'],
          row['benefits_granted'],
          row['evidence_checked'],
          row['savings_amount'],
          row['pp_outcome'],
          row['low_income_declared'],
          format_date(row['date_received']),
          format_date(row['decision_date']),
          format_date(row['date_fee_paid']),
          format_date(row['application_processed_date']),
          format_date(row['manual_process_date']),
          format_date(row['date_submitted_online']),
          row['statement_signed_by'],
          row['db_evidence_check_type'],
          row['db_income_check_type'],
          row['hmrc_total_income'],
          row['ev_check_outcome'],
          row['evidence_check_type'],
          row['hmrc_response'],
          row['hmrc_errors'],
          row['complete_processing'],
          row['additional_income'],
          row['income_processed'],
          format_hmrc_date_range(row['hmrc_request_date_range'])
        ]
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def estimated_applicant_pay(row)
        row['amount_to_pay'] || 0
      end

      def estimated_cost(row)
        fee = row['fee'].to_f
        amount_to_pay = row['amount_to_pay'].to_f
        fee - amount_to_pay
      end

      def final_applicant_pays(row)
        pp_outcome = row['pp_outcome']
        return row['fee'] if pp_outcome.present? && pp_outcome != 'part'

        row['ec_amount_to_pay'] || row['amount_to_pay'] || 0
      end

      def pension_age(row)
        row['over_66'] == true ? 'Yes' : 'No'
      end

      def format_date(value)
        return 'N/A' if value.blank?

        value.respond_to?(:strftime) ? value.strftime('%d/%m/%Y') : value.to_s
      end

      def format_hmrc_date_range(value)
        return 'N/A' if value.blank?

        params = YAML.safe_load(value, permitted_classes: [Symbol, Date])
        date_range = params[:date_range] || params['date_range']
        return 'N/A' unless date_range

        "#{date_range[:from] || date_range['from']} - #{date_range[:to] || date_range['to']}"
      rescue StandardError
        'N/A'
      end

      def zip_file
        log "Compressing to zip..."
        FileUtils.rm_f(@zipfile_path)

        Zip::File.open(@zipfile_path, create: true) do |zipfile|
          zipfile.add(@csv_file_name, @csv_file_path)
        end

        FileUtils.rm_f(@csv_file_path)
        log "  Compressed: #{File.size(@zipfile_path)} bytes"
      end

      def log(message)
        puts message if @verbose # rubocop:disable Rails/Output
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
