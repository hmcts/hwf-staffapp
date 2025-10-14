# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    class HmrcOcmcDataExport < ReportBase
      require 'csv'
      include OcmcExportHelper

      def initialize(start_date, end_date, office_id, all_offices: false)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date).end_of_day
        @office_id = office_id
        @all_offices = all_offices

        @csv_file_name = "help-with-fees-datashare-applications-by-court-extract-" \
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
          csv << data.first.keys
          data.each do |row|
            csv << process_row(row).values
          end
        end
      end

      private

      # rubocop:disable Metrics/MethodLength
      def sql_query
        "SELECT
        offices.name AS \"Office\",
        applications.reference as \"HwF reference number\",
        applications.created_at as \"Created at\",
        details.fee as \"Fee\",
        jurisdictions.name AS \"Jurisdiction\",
        applications.application_type as \"Application type\",
        details.form_name as \"Form\",
        details.refund as \"Refund\",
        CASE WHEN details.emergency_reason IS NULL THEN false ELSE true END AS \"Emergency\",
        applications.income as \"Income\",
        applications.income_period as \"Income period\",
        applications.children as \"Children\",
        applications.children_age_band as \"Age band under 14\",
        applications.children_age_band as \"Age band 14+\",
        CASE WHEN ec.id IS NULL THEN applications.amount_to_pay ELSE ec.amount_to_pay END as \"Applicant pays\",
        details.fee - applications.amount_to_pay as \"Departmental cost estimate\",
        CASE WHEN ec.id IS NULL THEN details.fee - applications.amount_to_pay ELSE details.fee - ec.amount_to_pay
          END as \"Departmental cost\",
        CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS \"Source\",
        CASE WHEN de.id IS NULL THEN 'no' ELSE 'yes' END AS \"Granted?\",
        CASE WHEN beo.id IS NULL THEN 'N/A'
               WHEN beo.correct = TRUE THEN 'Yes'
               WHEN beo.correct = FALSE THEN 'No'
          END AS \"Benefits granted?\",
        CASE WHEN ec.id IS NULL THEN 'no' ELSE 'yes' END AS \"Evidence checked?\",
        CASE WHEN savings.max_threshold_exceeded = TRUE then '16,000 or more'
             WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN '3,000 - 15,999'
             WHEN savings.max_threshold_exceeded = FALSE THEN '0 - 2,999'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN '0 - 2,999'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN '3000 or more'
             ELSE ''
        END AS \"Capital\",
        savings.amount AS \"Saving and Investments\",
        details.case_number AS \"Case number\",
        details.date_received as \"Date received\",
        CASE WHEN applicants.married = TRUE THEN 'yes' ELSE 'no' END as \"Married\",
        applications.decision as \"Decision\",
        applications.completed_at as \"Application processed date\",
        CASE WHEN ec.income_check_type = 'paper' THEN ec.completed_at ELSE NULL
        END as \"Manual evidence processed date\",
        CASE
          WHEN pp.completed_at IS NOT NULL THEN pp.completed_at
          WHEN applications.decision_type = 'evidence_check'
            AND applications.decision_date IS NOT NULL THEN applications.decision_date
          ELSE NULL
        END AS \"Processed date\",
        ec.outcome as \"EV check outcome\",
        pp.outcome as \"PP outcome\",
        applications.amount_to_pay as \"Applicant pays estimate\",
        applications.income_kind as \"Declared income sources\",
        ec.check_type as \"DB evidence check type\",
        ec.income_check_type as \"DB income check type\",
        ec.hmrc_income_used as \"HMRC total income\",
        CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIDuplicate'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' then 'HMRC NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' then 'HMRC NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' then 'HMRC NIDuplicate'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
           ELSE NULL
        END AS \"Evidence check type\",
        CASE WHEN hc_id IS NULL then NULL
           WHEN hc_id IS NOT NULL AND error_response IS NULL then 'Yes'
           WHEN hc_id IS NOT NULL AND error_response IS NOT NULL then 'No'
           ELSE NULL
        END AS \"HMRC response?\",
        error_response as \"HMRC errors\",
        CASE WHEN hc_id IS NULL then NULL
           WHEN hc_id IS NOT NULL AND ec.completed_at IS NOT NULL then 'Yes'
           WHEN hc_id IS NOT NULL AND ec.completed_at IS NULL then 'No'
           ELSE NULL
        END AS \"Complete processing?\",
        CASE WHEN additional_income IS NULL then NULL
           WHEN additional_income IS NOT NULL AND ec.income_check_type = 'paper' then NULL
           WHEN additional_income IS NOT NULL AND ec.income_check_type = 'hmrc'
            AND additional_income > 0 then additional_income
           ELSE NULL
        END as \"Additional income\",
        CASE WHEN ec.income IS NULL then applications.income
          WHEN ec.completed_at IS NOT NULL then ec.income
          ELSE NULL
        END as \"Income processed\",
        request_params as \"HMRC request date range\",
        details.statement_signed_by as \"Statement signed by\",
        CASE WHEN applicants.partner_ni_number IS NULL THEN 'false'
             WHEN applicants.partner_ni_number = '' THEN 'false'
             WHEN applicants.partner_ni_number IS NOT NULL THEN 'true'
             END AS \"Partner NI entered\",
        CASE WHEN applicants.partner_last_name IS NULL THEN 'false'
             WHEN applicants.partner_last_name IS NOT NULL THEN 'true'
             END AS \"Partner name entered\",
        details.calculation_scheme as \"HwF Scheme\",
        applications.deleted_reasons_list as \"Deletion Reason\",
        applications.deleted_reason as \"Reason Description\"

        FROM \"applications\" LEFT JOIN offices ON offices.id = applications.office_id
        LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
        LEFT JOIN part_payments pp ON pp.application_id = applications.id
        LEFT JOIN savings ON savings.application_id = applications.id
        LEFT JOIN decision_overrides de ON de.application_id = applications.id
        LEFT JOIN benefit_overrides beo ON beo.application_id = applications.id
        LEFT JOIN (
         SELECT id as \"hc_id\", income as \"hc_income\", request_params, tax_credit, additional_income,
            error_response, evidence_check_id, created_at, row_number() over
            (partition by evidence_check_id order by created_at desc)
            as row_number from hmrc_checks) hc ON ec.id = hc.evidence_check_id
        INNER JOIN \"applicants\" ON \"applicants\".\"application_id\" = \"applications\".\"id\"
        INNER JOIN \"details\" ON \"details\".\"application_id\" = \"applications\".\"id\"
        LEFT JOIN jurisdictions ON jurisdictions.id = details.jurisdiction_id
        WHERE applications.office_id = #{@office_id}
        AND applications.created_at between '#{@date_from.to_fs(:db)}' AND '#{@date_to.to_fs(:db)}'
        AND (row_number = 1 OR row_number IS NULL)
        AND applications.state != 0 ORDER BY applications.created_at DESC;"
      end

      # rubocop:disable Metrics/AbcSize
      def process_row(row)
        csv_row = row

        csv_row['Created at'] = csv_row['Created at'].to_fs(:db)
        csv_row['Application processed date'] = csv_row['Application processed date']&.to_fs(:db)
        csv_row['Manual evidence processed date'] = csv_row['Manual evidence processed date']&.to_fs(:db)
        csv_row['Processed date'] = csv_row['Processed date']&.to_fs(:db)
        csv_row['Declared income sources'] = income_kind(row['Declared income sources'])
        csv_row['HMRC request date range'] = hmrc_date_range(row['HMRC request date range'])
        csv_row['Age band under 14'] = children_age_band(row['Age band under 14'], :children_age_band_one)
        csv_row['Age band 14+'] = children_age_band(row['Age band 14+'], :children_age_band_two)

        row.each do |field, value|
          csv_row[field] = value.nil? ? 'N/A' : value
        end

        csv_row
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def income_kind(value) # rubocop:disable Metrics/MethodLength
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
      end # rubocop:enable Metrics/MethodLength

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
