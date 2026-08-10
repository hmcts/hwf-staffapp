
# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    class ApplicationsByCourtExport < ReportBase
      require 'csv'
      include ApplicationsByCourtExportHelper

      NUMERIC_FIELDS = [
        'estimated_amount_to_pay', 'final_amount_to_pay'
      ].freeze

      def initialize(start_date, end_date, office_id, all_offices: false)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date).end_of_day
        @office_id = office_id
        @all_offices = all_offices

        @csv_file_name = "help-with-fees-applications-by-court-extract-" \
                         "#{start_date[:day]}-#{start_date[:month]}-#{start_date[:year]}-" \
                         "#{end_date[:day]}-#{end_date[:month]}-#{end_date[:year]}.csv"
        @zipfile_path = "tmp/#{@csv_file_name}.zip"
      end

      def format_dates(date_attribute)
        DateTime.parse(date_attribute.values.join('/')).utc
      end

      def to_csv
        return "no results" unless data.first
        CSV.generate do |csv|
          # The SQL aliases columns to snake_case keys; the header row uses the
          # canonical labels from the single source of truth (ColumnLabels).
          csv << ColumnLabels.for(data.first.keys.map(&:to_sym))
          data.each do |row|
            csv << process_row(row).values
          end
        end
      end

      private

      def sql_query
        "(#{paper_applications_select}) UNION ALL (#{online_only_select}) ORDER BY created_at DESC;"
      end

      # rubocop:disable Metrics/MethodLength
      def paper_applications_select
        "SELECT
        offices.name AS office,
        applications.id AS id,
        CASE WHEN applications.state = 0 THEN 'Unprocessed'
             WHEN applications.state = 1 THEN 'Waiting for evidence'
             WHEN applications.state = 2 THEN 'Waiting for part-payment'
             WHEN applications.state = 3 THEN 'Completed'
             WHEN applications.state = 4 THEN 'Deleted'
             ELSE 'N/A'
        END AS status,
        applications.reference as reference,
        applications.created_at as created_at,
        details.fee as fee,
        details.fee_code AS fee_code,
        details.claim_amount AS claim_amount,
        CASE WHEN details.fee_entry_method = 'auto' THEN 'auto populated'
             WHEN details.fee_entry_method = 'manual' THEN 'entered'
             ELSE NULL
        END AS fee_population,
        jurisdictions.name AS jurisdiction,
        applications.application_type as application_type,
        details.form_name as form,
        details.refund as refund,
        CASE WHEN details.emergency_reason IS NULL THEN false ELSE true END AS emergency,
        COALESCE(applications.amount_to_pay, 0) as estimated_amount_to_pay,
        applications.income as pre_evidence_income,
        ec.income as post_evidence_income,
        CASE WHEN applications.income < 101 THEN 'true' ELSE 'false' END AS low_income_declared,
        applications.decision_date as decision_date,
        CASE WHEN COALESCE(applications.income_period, '') = ''
             THEN NULL
             ELSE applications.income_period
        END AS income_period,
        applications.children as children,
        applications.children_age_band as age_band_under_14,
        applications.children_age_band as age_band_14_plus,
        CASE WHEN ec.id IS NULL THEN COALESCE(applications.amount_to_pay, 0)
        ELSE COALESCE(ec.amount_to_pay, 0) END as final_amount_to_pay,
        details.fee - COALESCE(applications.amount_to_pay, 0) as estimated_cost,
        CASE WHEN ec.id IS NULL THEN details.fee - COALESCE(applications.amount_to_pay, 0)
        ELSE details.fee - COALESCE(ec.amount_to_pay, 0)
          END as departmental_cost,
        CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
        CASE WHEN de.id IS NULL THEN 'no' ELSE 'yes' END AS granted,
        CASE WHEN beo.id IS NULL THEN 'N/A'
               WHEN beo.correct = TRUE THEN 'Yes'
               WHEN beo.correct = FALSE THEN 'No'
          END AS benefits_granted,
        CASE WHEN ec.id IS NULL THEN 'no' ELSE 'yes' END AS evidence_checked,
        CASE WHEN savings.max_threshold_exceeded = TRUE then '16,000 or more'
             WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN '3,000 - 15,999'
             WHEN savings.max_threshold_exceeded = FALSE THEN '0 - 2,999'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN '0 - 2,999'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN '3000 or more'
             ELSE ''
        END AS capital_band,
        savings.amount AS savings_and_investments,
        details.case_number AS case_number,
        details.date_received as date_received,
        oa.created_at AS date_submitted_online,
        CASE WHEN applicants.married = TRUE THEN 'yes' ELSE 'no' END as married,
        CASE
          WHEN savings.over_66 = TRUE THEN 'Yes'
          WHEN savings.over_66 = FALSE THEN 'No'
          ELSE 'N/A'
        END AS pension_age,
        CASE WHEN applications.state = 4 THEN 'deleted' ELSE applications.decision END as decision,
        CASE WHEN savings.passed = FALSE then 'Yes'
             WHEN savings.passed = TRUE then 'No'
             ELSE 'N/A' END as failed_on_savings,
        applications.completed_at as application_processed_date,
        CASE WHEN ec.income_check_type = 'paper' THEN ec.completed_at ELSE NULL
        END as manual_evidence_processed_date,
        CASE
          WHEN pp.completed_at IS NOT NULL THEN pp.completed_at
          WHEN applications.decision_type = 'evidence_check'
            AND applications.decision_date IS NOT NULL THEN applications.decision_date
          ELSE NULL
        END AS processed_date,
        ec.outcome as evidence_check_outcome,
        pp.outcome as pp_outcome,
        applications.income_kind as declared_income_sources,
        ec.check_type as db_evidence_check_type,
        ec.income_check_type as db_income_check_type,
        ec.hmrc_income_used as hmrc_total_income,
        CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIDuplicate'
         WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'paper' AND hc_id IS NULL THEN 'Manual LowIncome'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' then 'HMRC NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' then 'HMRC NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' then 'HMRC NIDuplicate'
         WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'hmrc' THEN 'HMRC LowIncome'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
         WHEN ec.check_type = 'low_income' AND income_check_type = 'paper' AND hc_id IS NOT NULL THEN 'ManualAfterHMRC'
           ELSE NULL
        END AS evidence_check_type,
        CASE WHEN hc_id IS NULL then NULL
           WHEN hc_id IS NOT NULL AND error_response IS NULL then 'Yes'
           WHEN hc_id IS NOT NULL AND error_response IS NOT NULL then 'No'
           ELSE NULL
        END AS hmrc_response,
        error_response as hmrc_errors,
        CASE WHEN hc_id IS NULL then NULL
           WHEN hc_id IS NOT NULL AND ec.completed_at IS NOT NULL then 'Yes'
           WHEN hc_id IS NOT NULL AND ec.completed_at IS NULL then 'No'
           ELSE NULL
        END AS complete_processing,
        CASE WHEN additional_income IS NULL then NULL
           WHEN additional_income IS NOT NULL AND ec.income_check_type = 'paper' then NULL
           WHEN additional_income IS NOT NULL AND ec.income_check_type = 'hmrc'
            AND additional_income > 0 then additional_income
           ELSE NULL
        END as additional_income,
        CASE WHEN ec.income IS NULL then applications.income
          WHEN ec.completed_at IS NOT NULL then ec.income
          ELSE NULL
        END as income_processed,
        request_params as hmrc_request_date_range,
        details.statement_signed_by as statement_signed_by,
        CASE WHEN applicants.partner_ni_number IS NULL THEN 'false'
             WHEN applicants.partner_ni_number = '' THEN 'false'
             WHEN applicants.partner_ni_number IS NOT NULL THEN 'true'
             END AS partner_ni_entered,
        CASE WHEN applicants.partner_last_name IS NULL THEN 'false'
             WHEN applicants.partner_last_name IS NOT NULL THEN 'true'
             END AS partner_name_entered,
        details.calculation_scheme as hwf_scheme,
        applications.deleted_reasons_list as deletion_reason,
        applications.deleted_reason as reason_description

        FROM \"applications\" LEFT JOIN offices ON offices.id = applications.office_id
        LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
        LEFT JOIN part_payments pp ON pp.application_id = applications.id
        LEFT JOIN savings ON savings.application_id = applications.id
        LEFT JOIN decision_overrides de ON de.application_id = applications.id
        LEFT JOIN benefit_overrides beo ON beo.application_id = applications.id
        LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
        LEFT JOIN (
          SELECT DISTINCT ON (h.evidence_check_id)
            h.id AS hc_id, h.request_params, h.additional_income, h.error_response, h.evidence_check_id
          FROM hmrc_checks h
          INNER JOIN evidence_checks ec_inner ON ec_inner.id = h.evidence_check_id
          INNER JOIN applications a_inner ON a_inner.id = ec_inner.application_id
          WHERE a_inner.created_at BETWEEN '#{@date_from.to_fs(:db)}' AND '#{@date_to.to_fs(:db)}'
          ORDER BY h.evidence_check_id, h.created_at DESC
        ) hc ON ec.id = hc.evidence_check_id
        INNER JOIN \"applicants\" ON \"applicants\".\"application_id\" = \"applications\".\"id\"
        INNER JOIN \"details\" ON \"details\".\"application_id\" = \"applications\".\"id\"
        LEFT JOIN jurisdictions ON jurisdictions.id = details.jurisdiction_id
        WHERE offices.name NOT IN ('Digital', 'HMCTS HQ Team')
        #{paper_office_filter}
        AND applications.created_at between '#{@date_from.to_fs(:db)}' AND '#{@date_to.to_fs(:db)}'
        AND (applications.state != 0
          OR (applications.state = 0 AND details.date_received IS NOT NULL AND details.refund IS NOT NULL))
        ORDER BY applications.created_at DESC"
      end

      # No office filter when reporting on all offices or when none was chosen
      # (a blank office_id would otherwise produce `office_id = ` and break the SQL).
      def paper_office_filter
        return '' if selected?(@all_offices) || @office_id.blank?

        "AND applications.office_id = #{@office_id}"
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def online_only_select
        "SELECT
        offices.name AS office,
        online_applications.id AS id,
        'Unprocessed' AS status,
        online_applications.reference AS reference,
        online_applications.created_at AS created_at,
        online_applications.fee AS fee,
        online_applications.fee_code AS fee_code,
        online_applications.claim_amount AS claim_amount,
        CASE WHEN online_applications.fee_entry_method = 'auto' THEN 'auto populated'
             WHEN online_applications.fee_entry_method = 'manual' THEN 'entered'
             ELSE NULL
        END AS fee_population,
        jurisdictions.name AS jurisdiction,
        CASE WHEN online_applications.benefits THEN 'benefit' ELSE 'income' END AS application_type,
        online_applications.form_name AS form,
        online_applications.refund AS refund,
        CASE WHEN online_applications.emergency_reason IS NULL THEN false ELSE true END AS emergency,
        NULL AS estimated_amount_to_pay,
        online_applications.income AS pre_evidence_income,
        NULL AS post_evidence_income,
        CASE WHEN online_applications.income < 101 THEN 'true' ELSE 'false' END AS low_income_declared,
        NULL AS decision_date,
        CASE WHEN COALESCE(online_applications.income_period, '') = ''
             THEN NULL
             ELSE online_applications.income_period
        END AS income_period,
        online_applications.children AS children,
        online_applications.children_age_band AS age_band_under_14,
        online_applications.children_age_band AS age_band_14_plus,
        NULL AS final_amount_to_pay,
        NULL AS estimated_cost,
        NULL AS departmental_cost,
        'digital' AS source,
        NULL AS granted,
        NULL AS benefits_granted,
        'no' AS evidence_checked,
        NULL AS capital_band,
        online_applications.amount AS savings_and_investments,
        online_applications.case_number AS case_number,
        online_applications.date_received AS date_received,
        online_applications.created_at AS date_submitted_online,
        CASE WHEN online_applications.married = TRUE THEN 'yes' ELSE 'no' END AS married,
        NULL AS pension_age,
        NULL AS decision,
        NULL AS failed_on_savings,
        NULL AS application_processed_date,
        NULL AS manual_evidence_processed_date,
        NULL AS processed_date,
        NULL AS evidence_check_outcome,
        NULL AS pp_outcome,
        online_applications.income_kind AS declared_income_sources,
        NULL AS db_evidence_check_type,
        NULL AS db_income_check_type,
        NULL AS hmrc_total_income,
        NULL AS evidence_check_type,
        NULL AS hmrc_response,
        NULL AS hmrc_errors,
        NULL AS complete_processing,
        NULL AS additional_income,
        online_applications.income AS income_processed,
        NULL AS hmrc_request_date_range,
        online_applications.statement_signed_by AS statement_signed_by,
        CASE WHEN online_applications.partner_ni_number IS NULL THEN 'false'
             WHEN online_applications.partner_ni_number = '' THEN 'false'
             WHEN online_applications.partner_ni_number IS NOT NULL THEN 'true'
        END AS partner_ni_entered,
        CASE WHEN online_applications.partner_last_name IS NULL THEN 'false'
             WHEN online_applications.partner_last_name IS NOT NULL THEN 'true'
        END AS partner_name_entered,
        online_applications.calculation_scheme AS hwf_scheme,
        NULL AS deletion_reason,
        NULL AS reason_description
        FROM online_applications
        INNER JOIN users ON users.id = online_applications.user_id
        INNER JOIN offices ON offices.id = users.office_id
        LEFT JOIN applications ON applications.online_application_id = online_applications.id
        LEFT JOIN jurisdictions ON jurisdictions.id = online_applications.jurisdiction_id
        WHERE applications.id IS NULL
        AND online_applications.date_received IS NOT NULL
        AND online_applications.created_at BETWEEN '#{@date_from.to_fs(:db)}' AND '#{@date_to.to_fs(:db)}'
        AND offices.name NOT IN ('Digital', 'HMCTS HQ Team')
        #{online_office_filter}"
      end
      # rubocop:enable Metrics/MethodLength

      def online_office_filter
        return '' if selected?(@all_offices) || @office_id.blank?
        "AND users.office_id = #{@office_id}"
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def process_row(row)
        csv_row = row

        csv_row['created_at'] = csv_row['created_at'].to_fs(:db)
        csv_row['application_processed_date'] = csv_row['application_processed_date']&.to_fs(:db)
        csv_row['manual_evidence_processed_date'] = csv_row['manual_evidence_processed_date']&.to_fs(:db)
        csv_row['processed_date'] = csv_row['processed_date']&.to_fs(:db)
        csv_row['decision_date'] = csv_row['decision_date']&.to_fs(:db)
        csv_row['date_submitted_online'] = csv_row['date_submitted_online']&.to_fs(:db)
        csv_row['declared_income_sources'] = income_kind(row['declared_income_sources'])
        csv_row['hmrc_request_date_range'] = hmrc_date_range(row['hmrc_request_date_range'])
        csv_row['age_band_under_14'] = children_age_band(row['age_band_under_14'], :children_age_band_one)
        csv_row['age_band_14_plus'] = children_age_band(row['age_band_14_plus'], :children_age_band_two)

        row.each do |field, value|
          csv_row[field] = numberic_values_check(value, field)
        end

        csv_row
      end

      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      def numberic_values_check(value, field)
        if value.nil?
          NUMERIC_FIELDS.include?(field) ? 0 : 'N/A'
        else
          value
        end
      end

      def income_kind(value) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        return 'N/A' if value.nil?
        income_kind_hash = YAML.parse(value).to_ruby
        return 'N/A' if income_kind_hash.blank?
        applicant = IncomeTypesInput.normalize_list(income_kind_hash[:applicant]).map do |kind|
          I18n.t(kind, scope: ['activemodel.attributes.forms/application/income_kind_applicant', 'kinds'])
        end.join(',')
        partner = IncomeTypesInput.normalize_list(income_kind_hash[:partner]).try(:map) do |kind|
          I18n.t(kind, scope: ['activemodel.attributes.forms/application/income_kind_partner', 'kinds'])
        end.try(:join, ',')
        [applicant, partner].compact_blank.join(", ")
      rescue TypeError
        "N/A"
      end # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def date_formatted(date_range)
        return nil if date_range.blank?
        request_params_hash = YAML.parse(date_range).to_ruby
        request_params_hash[:date_range]
      end

      def hmrc_date_range(date_range)
        return 'N/A' unless date_formatted(date_range)
        from = date_formatted(date_range)[:from]
        to = date_formatted(date_range)[:to]
        "#{from} - #{to}"
      end

    end
  end
end
# rubocop:enable Metrics/ClassLength
