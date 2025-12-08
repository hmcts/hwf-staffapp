# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    class RawDataExport < ReportBase

      FIELDS = {
        id: 'id',
        name: 'office',
        reference: 'reference',
        jurisdiction: 'jurisdiction',
        sop_code: 'SOP code',
        fee: 'fee',
        estimated_amount_to_pay: 'estimated applicant pay',
        estimated_cost: 'estimated cost',
        application_type: 'application type',
        form_name: 'form',
        refund: 'refund',
        emergency: 'emergency',
        income: 'pre evidence income',
        check_income: 'post evidence income',
        income_period: 'income period',
        reg_number: 'ho/ni number',
        children: 'children',
        children_age_band_one: 'age band under 14',
        children_age_band_two: 'age band 14+',
        married: 'married',
        over_66: 'pension age',
        decision: 'decision',
        saving_failed: 'Failed on savings',
        final_amount_to_pay: 'final applicant pays',
        decision_cost: 'departmental cost',
        source: 'source',
        granted: 'granted?',
        benefits_granted: 'benefits granted?',
        evidence_checked: 'evidence checked?',
        capital: 'capital band',
        savings_amount: 'savings and investments amount',
        part_payment_outcome: 'part payment outcome',
        low_income_declared: 'low income declared',
        case_number: 'case number',
        postcode: 'postcode',
        date_of_birth: 'date of birth',
        date_received: 'date received',
        decision_date: 'decision date',
        date_fee_paid: 'date paid',
        manual_process_date: 'manual evidence processed date',
        date_submitted_online: 'date submitted online',
        statement_signed_by: 'statement signed by',
        partner_ni: 'partner ni entered',
        partner_name: 'partner name entered',
        calculation_scheme: 'HwF Scheme',
        db_evidence_check_type: 'DB evidence check type',
        db_income_check_type: 'DB income check type',
        hmrc_total_income: 'HMRC total income',
        evidence_check_type: 'evidence check type',
        hmrc_response: 'HMRC response?',
        hmrc_errors: 'HMRC errors',
        complete_processing: 'complete processing?',
        additional_income: 'additional income',
        hmrc_request_date_range: 'HMRC request date range'
      }.freeze

      HEADERS = FIELDS.values
      ATTRIBUTES = FIELDS.keys

      def initialize(start_date, end_date, court_id = nil)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date).end_of_day
        @court_id = court_id

        @csv_file_name = "raw_data-#{start_date.values.join('-')}-#{end_date.values.join('-')}.csv"
        @zipfile_path = "tmp/#{@csv_file_name}.zip"
      end

      def to_csv
        CSV.generate do |csv|
          csv << HEADERS
          data.each do |row|
            csv << ATTRIBUTES.map do |attr|
              process_row(row, attr)
            end
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def process_row(row, attr)
        if [:estimated_cost, :estimated_amount_to_pay, :reg_number,
            :final_amount_to_pay].include?(attr)
          send(attr, row)
        elsif [:date_received, :decision_date, :date_fee_paid, :date_of_birth,
               :date_submitted_online, :manual_process_date, :processed_date].include?(attr)
          date_value = row[attr.to_s]
          if date_value.present?
            date_value.respond_to?(:to_fs) ? date_value.to_fs(:default) : Date.parse(date_value.to_s).to_fs(:default)
          else
            'N/A'
          end
        elsif [:children_age_band_two, :children_age_band_one].include?(attr)
          children_age_band(row, attr)
        elsif attr == :over_66
          over_66?(row)
        elsif [:case_number, :form_name].include?(attr)
          row[attr.to_s].presence || 'N/A'
        elsif [:hmrc_request_date_range].include?(attr)
          hmrc_date_range(row[attr.to_s]) || 'N/A'
        else
          check_empty(attr, row)
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      def total_count
        data.size
      end

      def tidy_up
        FileUtils.rm_f(zipfile_path)
      end

      private

      def data
        @data ||= build_data
      end

      def build_data
        sql = build_sql_query
        ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:with_indifferent_access)
      end

      # rubocop:disable Metrics/MethodLength
      def build_sql_query
        <<~SQL.squish
          SELECT#{' '}
            applications.id,
            applications.reference,
            applications.children_age_band,
            details.fee,
            details.form_name,
            details.refund,
            details.statement_signed_by,
            applications.application_type,
            applications.income,
            applications.income_period,
            applications.children,
            applications.decision,
            applications.amount_to_pay,
            applications.decision_cost,
            applicants.married,
            applicants.partner_ni_number,
            applicants.partner_last_name,
            applications.income_min_threshold_exceeded,
            applications.income_max_threshold_exceeded,
            applicants.ni_number,
            applicants.ho_number,
            offices.name AS name,
            details.emergency_reason IS NOT NULL AS emergency,
            jurisdictions.name AS jurisdiction,
            business_entities.sop_code AS sop_code,
            part_payments.outcome AS pp_outcome,
            CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
            CASE WHEN de.id IS NULL THEN false ELSE true END AS granted,
            CASE WHEN beo.id IS NULL THEN 'N/A'
                 WHEN beo.correct = TRUE THEN 'Yes'
                 WHEN beo.correct = FALSE THEN 'No'
            END AS benefits_granted,
            CASE WHEN ec.id IS NULL THEN false ELSE true END AS evidence_checked,
            CASE WHEN savings.max_threshold_exceeded = TRUE then 'High'
                 WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN 'Medium'
                 WHEN savings.max_threshold_exceeded = FALSE THEN 'Low'
                 WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN 'Low'
                 WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN 'High'
                 ELSE 'N/A'
            END AS capital,
            CASE WHEN savings.passed = FALSE then 'Yes'
                WHEN savings.passed = TRUE then 'No'
                ELSE 'N/A' END AS saving_failed,
            CASE WHEN part_payments.outcome = 'return' THEN 'return'
                 WHEN part_payments.outcome = 'none' THEN 'false'
                 WHEN part_payments.outcome = 'part' THEN 'true' ELSE 'N/A' END AS part_payment_outcome,
            CASE WHEN savings.amount >= 16000 THEN NULL
                 ELSE savings.amount
            END AS savings_amount,
            CASE WHEN ec.income_check_type = 'paper' THEN ec.completed_at ELSE NULL END as manual_process_date,
            savings.over_66 AS over_66,
            details.case_number AS case_number,
            oa.postcode AS postcode,
            applicants.date_of_birth AS date_of_birth,
            details.date_received AS date_received,
            applications.decision_date AS decision_date,
            details.date_fee_paid AS date_fee_paid,
            oa.created_at AS date_submitted_online,
            details.statement_signed_by AS statement_signed_by,
            details.calculation_scheme AS calculation_scheme,
            ec.income AS check_income,
            ec.amount_to_pay AS evidence_check_amount_to_pay,
            CASE WHEN applicants.partner_ni_number IS NULL THEN 'false'
                 WHEN applicants.partner_ni_number = '' THEN 'false'
                 WHEN applicants.partner_ni_number IS NOT NULL THEN 'true'
                 END AS partner_ni,
            CASE WHEN applicants.partner_last_name IS NULL THEN 'false'
                 WHEN applicants.partner_last_name IS NOT NULL THEN 'true'
                 END AS partner_name,
            CASE WHEN applications.income <= 101 THEN 'true' ELSE 'false' END AS low_income_declared,
            ec.check_type as db_evidence_check_type,
            ec.income_check_type as db_income_check_type,
            ec.hmrc_income_used as hmrc_total_income,
            CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL then 'Manual NumberRule'
            WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL then 'Manual NIFlag'
            WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL then 'Manual NIDuplicate'
            WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' then 'HMRC NumberRule'
            WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' then 'HMRC NIFlag'
            WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' then 'HMRC NIDuplicate'
            WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL then 'ManualAfterHMRC'
            WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL then 'ManualAfterHMRC'
              ELSE NULL
            END AS evidence_check_type,
            CASE WHEN hc.hc_id IS NULL then NULL
              WHEN hc.hc_id IS NOT NULL AND hc.error_response IS NULL then 'Yes'
              WHEN hc.hc_id IS NOT NULL AND hc.error_response IS NOT NULL then 'No'
              ELSE NULL
            END AS hmrc_response,
            hc.error_response as hmrc_errors,
            CASE WHEN hc.hc_id IS NULL then NULL
              WHEN hc.hc_id IS NOT NULL AND ec.completed_at IS NOT NULL then 'Yes'
              WHEN hc.hc_id IS NOT NULL AND ec.completed_at IS NULL then 'No'
              ELSE NULL
            END AS complete_processing,
            CASE WHEN hc.additional_income IS NULL then NULL
              WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'paper' then NULL
              WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'hmrc'
                AND hc.additional_income > 0 then hc.additional_income
              ELSE NULL
            END as additional_income,
            hc.request_params as hmrc_request_date_range
          FROM applications
          INNER JOIN applicants ON applicants.application_id = applications.id
          INNER JOIN business_entities ON business_entities.id = applications.business_entity_id
          INNER JOIN details ON details.application_id = applications.id
          INNER JOIN jurisdictions ON jurisdictions.id = details.jurisdiction_id
          LEFT JOIN offices ON offices.id = applications.office_id
          LEFT JOIN decision_overrides de ON de.application_id = applications.id
          LEFT JOIN benefit_overrides beo ON beo.application_id = applications.id
          LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
          LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
          LEFT JOIN savings ON savings.application_id = applications.id
          LEFT JOIN part_payments ON part_payments.application_id = applications.id
          LEFT JOIN (
            SELECT id as hc_id, income as hc_income, request_params, tax_credit, additional_income,
            error_response, evidence_check_id, created_at, row_number() over
            (partition by evidence_check_id order by created_at desc)
            as row_number from hmrc_checks
          ) hc ON ec.id = hc.evidence_check_id AND (hc.row_number = 1 OR hc.row_number IS NULL)
          WHERE offices.name NOT IN ('Digital')
            AND applications.decision_date >= '#{@date_from.strftime('%Y-%m-%d %H:%M:%S')}'
            AND applications.decision_date <= '#{@date_to.strftime('%Y-%m-%d %H:%M:%S')}'
            AND applications.state = #{Application.states[:processed]}
            #{"AND applications.office_id = #{@court_id}" if @court_id.present?}
        SQL
      end
      # rubocop:enable Metrics/MethodLength

      def estimated_cost(row)
        (row['fee'] - row['amount_to_pay'].to_f) || 0
      end

      def estimated_amount_to_pay(row)
        row['amount_to_pay'] || 0
      end

      def final_amount_to_pay(row)
        return row['fee'] if row['pp_outcome'].present? && row['pp_outcome'] != 'part'
        ec_amount = row['evidence_check_amount_to_pay']
        ec_amount || row['amount_to_pay']
      end

      def reg_number(row)
        return 'NI number' if row['ni_number'].present?
        return 'Home Office number' if row['ho_number'].present?
        'None'
      end

      def over_66?(row)
        row['over_66'] == true ? 'Yes' : 'No'
      end

      def low_income_declared(row)
        return 'false' if row['income'].blank?
        row['income'] <= 101
      end

      def date_for_age_calculation(row)
        row['date_submitted_online'] || row['date_received']
      end

      def age_band_parse(age_band_value)
        return {} unless age_band_value.is_a?(String)
        YAML.safe_load(age_band_value, permitted_classes: [], permitted_symbols: [:one, :two], aliases: true)
      rescue StandardError
        begin
          YAML.load(age_band_value)
        rescue StandardError
          {}
        end
      end

      def children_age_band(row, attr_key)
        return 'N/A' if age_bands_blank?(row)

        children_age_band_parsed = age_band_parse(row['children_age_band'])

        if attr_key == :children_age_band_one
          children_age_band_parsed[:one] || children_age_band_parsed['one']
        elsif attr_key == :children_age_band_two
          children_age_band_parsed[:two] || children_age_band_parsed['two']
        end
      end

      def age_bands_blank?(row)
        return true if row['children_age_band'].blank?
        children_age_band_parsed = age_band_parse(row['children_age_band'])

        return true unless children_age_band_parsed.is_a?(Hash)

        children_age_band_parsed.keys.select do |key|
          ['one', 'two'].include?(key.to_s)
        end.blank?
      end

      def check_empty(attribute, row)
        return 'N/A' if row[attribute.to_s].nil?
        row[attribute.to_s]
      end

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
