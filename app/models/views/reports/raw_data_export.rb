# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    class RawDataExport
      require 'csv'

      FIELDS = {
        id: 'id',
        name: 'office',
        jurisdiction: 'jurisdiction',
        bec_code: 'BEC code',
        fee: 'fee',
        estimated_amount_to_pay: 'estimated applicant pay',
        estimated_cost: 'estimated cost',
        application_type: 'application type',
        form_name: 'form',
        probate: 'probate',
        refund: 'refund',
        emergency: 'emergency',
        income: 'income',
        income_threshold: 'income_threshold exceeded',
        reg_number: 'ho/ni number',
        children: 'children',
        married: 'married',
        decision: 'decision',
        final_amount_to_pay: 'final applicant pays',
        decision_cost: 'departmental cost',
        source: 'source',
        granted: 'granted?',
        evidence_checked: 'evidence checked?',
        capital: 'capital',
        savings_amount: 'savings and investments amount',
        case_number: 'case number',
        postcode: 'postcode',
        date_of_birth: 'date of birth',
        date_received: 'date received',
        date_fee_paid: 'date paid',
        date_submitted_online: 'date submitted online'
      }.freeze

      HEADERS = FIELDS.values
      ATTRIBUTES = FIELDS.keys

      def initialize(start_date, end_date)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date).end_of_day
      end

      def format_dates(date_attribute)
        DateTime.parse(date_attribute.values.join('/')).utc
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

      def process_row(row, attr)
        if attr == :estimated_cost
          estimated_decision_cost_calculation(row)
        elsif attr == :estimated_amount_to_pay
          estimation_amount_to_pay(row)
        elsif [:reg_number, :income_threshold, :final_amount_to_pay].include?(attr)
          send(attr, row)
        else
          row.send(attr)
        end
      end

      def total_count
        data.size
      end

      private

      def data
        @data ||= build_data
      end

      def build_data
        Application.
          select('id', 'details.fee', 'details.form_name', 'details.probate', 'details.refund',
                 'application_type', 'income', 'children', 'decision', 'amount_to_pay',
                 'decision_cost', 'applicants.married', 'income_min_threshold_exceeded',
                 'income_max_threshold_exceeded').
          select(named_columns).
          joins(joins).
          joins(:applicant, :business_entity, detail: :jurisdiction).
          where("offices.name NOT IN ('Digital')").
          where(decision_date: @date_from..@date_to, state: Application.states[:processed])
      end

      def named_columns
        <<~COLUMNS
          offices.name AS name,
          details.emergency_reason IS NOT NULL AS emergency,
          jurisdictions.name AS jurisdiction,
          business_entities.be_code AS bec_code,
          part_payments.outcome AS pp_outcome,
          CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
          CASE WHEN de.id IS NULL THEN false ELSE true END AS granted,
          CASE WHEN ec.id IS NULL THEN false ELSE true END AS evidence_checked,
          CASE WHEN savings.max_threshold_exceeded = TRUE then '16,000 or more'
               WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN '3,000 - 15,999'
               WHEN savings.max_threshold_exceeded = FALSE THEN '0 - 2,999'
               WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN '0 - 2,999'
               WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN '3000 or more'
               ELSE ''
          END AS capital,
          savings.amount AS savings_amount,
          details.case_number AS case_number,
          oa.postcode AS postcode,
          applicants.date_of_birth AS date_of_birth,
          details.date_received AS date_received,
          details.date_fee_paid AS date_fee_paid,
          oa.created_at AS date_submitted_online
        COLUMNS
      end

      def joins
        <<~JOINS
          LEFT JOIN offices ON offices.id = applications.office_id
          LEFT JOIN decision_overrides de ON de.application_id = applications.id
          LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
          LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
          LEFT JOIN savings ON savings.application_id = applications.id
          LEFT JOIN part_payments ON part_payments.application_id = applications.id
        JOINS
      end

      def estimated_decision_cost_calculation(row)
        (row.fee - row.amount_to_pay.to_f) || 0
      end

      def estimation_amount_to_pay(row)
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
      end

    end
  end
end
# rubocop:enable Metrics/ClassLength
