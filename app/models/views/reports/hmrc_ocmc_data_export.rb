# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    class HmrcOcmcDataExport
      require 'csv'

      def initialize(start_date, end_date, office_id)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date).end_of_day
        @office_id = office_id
      end

      def format_dates(date_attribute)
        DateTime.parse(date_attribute.values.join('/')).utc
      end

      def to_csv
        return "no results" unless data.first
        CSV.generate do |csv|
          csv << data.first.keys - ['tax_credit']
          data.each do |row|
            csv << process_row(row).values
          end
        end
      end

      private

      def data
        @data ||= build_data
      end

      def build_data
        ActiveRecord::Base.connection.execute(sql_query)
      end

      # rubocop:disable Metrics/MethodLength
      def sql_query
        "SELECT
        offices.name AS \"Office\",
        applications.reference as \"HwF reference number\",
        applications.created_at as \"Created at\",
        details.fee as \"Fee\",
        applications.application_type as \"Application type\",
        details.form_name as \"Form\",
        details.refund as \"Refund\",
        applications.income as \"Income\",
        applications.children as \"Children\",
        CASE WHEN ec.id IS NULL THEN applications.amount_to_pay ELSE ec.amount_to_pay END as \"Applicant pays\",
        details.fee - applications.amount_to_pay as \"Departmental cost estimate\",
        CASE WHEN ec.id IS NULL THEN details.fee - applications.amount_to_pay ELSE details.fee - ec.amount_to_pay
          END as \"Departmental cost\",
        CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS \"Source\",
        CASE WHEN de.id IS NULL THEN 'no' ELSE 'yes' END AS \"Granted?\",
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
        applications.amount_to_pay as \"Applicant pays estimate\",
        applications.income_kind as \"Declared income sources\",
        ec.check_type as \"DB evidence check type\",
        ec.income_check_type as \"DB income check type\",
        CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.id IS NULL then 'Manual NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.id IS NULL then 'Manual NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc.id IS NULL then 'Manual NIDuplicate'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' then 'HMRC NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' then 'HMRC NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' then 'HMRC NIDuplicate'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.id IS NOT NULL then 'ManualAfterHMRC'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.id IS NOT NULL then 'ManualAfterHMRC'
           ELSE ''
        END AS \"Evidence check type\",
        CASE WHEN hc.id IS NULL then ''
           WHEN hc.id IS NOT NULL AND hc.error_response IS NULL then 'Yes'
           WHEN hc.id IS NOT NULL AND hc.error_response IS NOT NULL then 'No'
           ELSE ''
        END AS \"HMRC response?\",
        hc.error_response as \"HMRC errors\",
        CASE WHEN hc.id IS NULL then ''
           WHEN hc.id IS NOT NULL AND ec.completed_at IS NOT NULL then 'Yes'
           WHEN hc.id IS NOT NULL AND ec.completed_at IS NULL then 'No'
           ELSE ''
        END AS \"Complete processing?\",
        CASE WHEN hc.income IS NULL then ''
           WHEN hc.income IS NOT NULL then hc.income
           ELSE ''
        END as \"HMRC total income\",
        CASE WHEN hc.additional_income IS NULL then NULL
           WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'paper' then NULL
           WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'hmrc'
            AND hc.additional_income > 0 then hc.additional_income
           ELSE NULL
        END as \"Additional income\",
        CASE WHEN hc.id IS NULL then NULL
           WHEN ec.income_check_type = 'paper' AND ec.completed_at IS NOT NULL then NULL
           WHEN ec.income_check_type = 'hmrc' AND ec.completed_at IS NOT NULL then ec.income
           ELSE NULL
        END as \"Income processed\",
        hc.tax_credit
        FROM \"applications\" LEFT JOIN offices ON offices.id = applications.office_id
        LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
        LEFT JOIN savings ON savings.application_id = applications.id
        LEFT JOIN decision_overrides de ON de.application_id = applications.id
        LEFT JOIN hmrc_checks hc ON ec.id = hc.evidence_check_id
        INNER JOIN \"applicants\" ON \"applicants\".\"application_id\" = \"applications\".\"id\"
        INNER JOIN \"details\" ON \"details\".\"application_id\" = \"applications\".\"id\"
        WHERE applications.office_id = #{@office_id}
        AND applications.created_at between '#{@date_from.to_s(:db)}' AND '#{@date_to.to_s(:db)}'
        AND applications.state != 0 ORDER BY applications.created_at DESC;"
      end
      # rubocop:enable Metrics/MethodLength

      def process_row(row)
        csv_row = row
        csv_row['Declared income sources'] = income_kind(row['Declared income sources'])
        csv_row['HMRC total income'] = hmrc_total_income(row)
        csv_row['tax_credit'] = ''
        csv_row
      end

      def income_kind(value)
        return unless value
        income_kind_hash = YAML.parse(value).to_ruby
        return if income_kind_hash.blank?
        applicant = income_kind_hash[:applicant].join(',')
        partner = income_kind_hash[:partner].try(:join, ',')
        [applicant, partner].reject(&:blank?).join(", ")
      rescue TypeError
        ""
      end

      def hmrc_total_income(row)
        paye = hmrc_income(row['HMRC total income'])
        tax_credits = tax_credit(row['tax_credit'])
        total = paye + tax_credits
        total.positive? ? total : ''
      end

      def hmrc_income(value)
        return 0 if value.blank?
        income_hash = YAML.parse(value).to_ruby
        HmrcIncomeParser.paye(income_hash)
      end

      def tax_credit(value)
        return 0 if value.blank?
        tax_credit_hash = YAML.parse(value).to_ruby
        work = HmrcIncomeParser.tax_credit(tax_credit_hash.try(:[], :work))
        child = HmrcIncomeParser.tax_credit(tax_credit_hash.try(:[], :child))
        work + child
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
