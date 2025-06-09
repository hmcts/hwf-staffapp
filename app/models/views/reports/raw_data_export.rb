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
        probate: 'probate',
        refund: 'refund',
        emergency: 'emergency',
        income: 'pre evidence income',
        check_income: 'post evidence income',
        income_threshold: 'income_threshold exceeded',
        income_period: 'income period',
        reg_number: 'ho/ni number',
        children: 'children',
        children_age_band_one: 'age band under 14',
        children_age_band_two: 'age band 14+',
        married: 'married',
        over_66: 'pension age',
        decision: 'decision',
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
        decision_date: 'application processed date',
        date_fee_paid: 'date paid',
        manual_process_date: 'manual evidence processed date',
        processed_date: 'processed date',
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
        if [:estimated_cost, :estimated_amount_to_pay, :reg_number, :income_threshold,
            :final_amount_to_pay].include?(attr)
          send(attr, row)
        elsif [:date_received, :decision_date, :date_fee_paid, :date_of_birth,
               :date_submitted_online, :manual_process_date, :processed_date].include?(attr)
          row.send(attr).present? ? row.send(attr).to_fs(:default) : 'N/A'
        elsif [:children_age_band_two, :children_age_band_one].include?(attr)
          children_age_band(row, attr)
        elsif attr == :over_66
          over_66?(row)
        elsif attr == :low_income_declared
          low_income_declared(row)
        elsif [:case_number, :form_name].include?(attr)
          row.send(attr).presence || 'N/A'
        elsif [:hmrc_request_date_range].include?(attr)
          hmrc_date_range(row.send(attr)) || 'N/A'
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
        query = Application.
                select(simple_columns).
                select(named_columns).
                joins(joins).
                joins(:applicant, :business_entity, detail: :jurisdiction).
                where("offices.name NOT IN ('Digital')").
                where(decision_date: @date_from..@date_to, state: Application.states[:processed])

        query = query.where(office_id: @court_id) if @court_id.present?
        query
      end

      def simple_columns
        ['id', 'reference', 'children_age_band', 'details.fee', 'details.form_name', 'details.probate',
         'details.refund', 'details.statement_signed_by', 'application_type', 'income', 'income_period',
         'children', 'decision', 'amount_to_pay', 'decision_cost', 'applicants.married',
         'applicants.partner_ni_number', 'applicants.partner_last_name',
         'income_min_threshold_exceeded', 'income_max_threshold_exceeded']
      end

      def named_columns
        <<~COLUMNS
          offices.name AS name,
          details.emergency_reason IS NOT NULL AS emergency,
          jurisdictions.name AS jurisdiction,
          business_entities.sop_code AS sop_code,
          part_payments.outcome AS pp_outcome,
          CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
          CASE WHEN de.id IS NULL THEN false ELSE true END AS granted,
          CASE WHEN beo.id IS NULL THEN false ELSE true END AS benefits_granted,
          CASE WHEN ec.id IS NULL THEN false ELSE true END AS evidence_checked,
          CASE WHEN savings.max_threshold_exceeded = TRUE then 'High'
               WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN 'Medium'
               WHEN savings.max_threshold_exceeded = FALSE THEN 'Low'
               WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN 'Low'
               WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN 'High'
               ELSE 'N/A'
          END AS capital,
          CASE WHEN part_payments.outcome = 'return' THEN 'return'
               WHEN part_payments.outcome = 'none' THEN 'false'
               WHEN part_payments.outcome = 'part' THEN 'true' ELSE 'N/A' END AS part_payment_outcome,
          CASE WHEN savings.amount >= 16000 THEN NULL
               ELSE savings.amount
          END AS savings_amount,
          CASE WHEN ec.income_check_type = 'paper' THEN ec.completed_at ELSE NULL END as manual_process_date,
          CASE WHEN part_payments.completed_at IS NOT NULL THEN part_payments.completed_at
               WHEN applications.decision_type = 'evidence_check'
               AND applications.decision_date IS NOT NULL THEN applications.decision_date
          ELSE NULL END AS processed_date,
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
          CASE WHEN applicants.partner_ni_number IS NULL THEN 'false'
               WHEN applicants.partner_ni_number = '' THEN 'false'
               WHEN applicants.partner_ni_number IS NOT NULL THEN 'true'
               END AS partner_ni,
          CASE WHEN applicants.partner_last_name IS NULL THEN 'false'
               WHEN applicants.partner_last_name IS NOT NULL THEN 'true'
               END AS partner_name,
          CASE WHEN applications.income < 101 THEN 'true' ELSE 'false' END AS low_income_declared,
          ec.check_type as db_evidence_check_type,
          ec.income_check_type as db_income_check_type,
          ec.hmrc_income_used as hmrc_total_income,
          CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NumberRule'
          WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIFlag'
          WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIDuplicate'
          WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' then 'HMRC NumberRule'
          WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' then 'HMRC NIFlag'
          WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' then 'HMRC NIDuplicate'
          WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
          WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
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
          request_params as hmrc_request_date_range
        COLUMNS
      end

      def joins
        <<~JOINS
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
            as row_number from hmrc_checks) hc ON ec.id = hc.evidence_check_id
        JOINS
      end

      def estimated_cost(row)
        (row.fee - row.amount_to_pay.to_f) || 0
      end

      def estimated_amount_to_pay(row)
        row.amount_to_pay || 0
      end

      def final_amount_to_pay(row)
        return row.fee if row.try(:pp_outcome).present? && row.pp_outcome != 'part'
        ec_amount = row.evidence_check.try(:amount_to_pay)
        ec_amount || row.amount_to_pay
      end

      def reg_number(row)
        return 'NI number' if row.applicant.ni_number.present?
        return 'Home Office number' if row.applicant.ho_number.present?
        'None'
      end

      def income_threshold(row)
        return 'under' if row.income_min_threshold_exceeded
        return 'over' if row.income_max_threshold_exceeded
        'N/A'
      end

      def over_66?(row)
        row.send(:over_66) == true ? 'Yes' : 'No'
      end

      def low_income_declared(row)
        # return "low_income_declared"
        return 'false' if row.income.blank?
        row.income <= 101
      end

      def date_for_age_calculation(row)
        row.send(:date_submitted_online) || row.send(:date_received)
      end

      def children_age_band(row, attr_key)
        return 'N/A' if age_bands_blank?(row)

        if attr_key == :children_age_band_one
          row.children_age_band[:one] || row.children_age_band['one']
        elsif attr_key == :children_age_band_two
          row.children_age_band[:two] || row.children_age_band['two']
        end
      end

      def age_bands_blank?(row)
        return true if row.children_age_band.blank?

        row.children_age_band.keys.select do |key|
          ['one', 'two'].include?(key.to_s)
        end.blank?
      end

      def check_empty(attribute, row)
        return 'N/A' if row.send(attribute).nil?
        row.send(attribute)
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
