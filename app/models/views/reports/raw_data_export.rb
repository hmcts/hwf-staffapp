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
        application_type: 'application type',
        form_name: 'form',
        probate: 'probate',
        refund: 'refund',
        emergency: 'emergency',
        income: 'income',
        children: 'children',
        married: 'married',
        decision: 'decision',
        amount_to_pay: 'applicant pays',
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
        date_submitted_online: 'date submitted online'
      }.freeze

      HEADERS = FIELDS.values
      ATTRIBUTES = FIELDS.keys

      def initialize(start_date, end_date)
        @date_from = DateTime.parse(start_date.to_s).utc
        @date_to = DateTime.parse(end_date.to_s).utc.end_of_day
      end

      def to_csv
        CSV.generate do |csv|
          csv << HEADERS

          data.each do |row|
            csv << ATTRIBUTES.map { |attr| row.send(attr) }
          end
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
                 'decision_cost', 'applicants.married').
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
          CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
          CASE WHEN de.id IS NULL THEN false ELSE true END AS granted,
          CASE WHEN ec.id IS NULL THEN false ELSE true END AS evidence_checked,
          CASE WHEN savings.max_threshold_exceeded = TRUE then '16,000+'
               WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN '3,000 - 15,999'
               WHEN savings.max_threshold_exceeded = FALSE THEN '0 - 2,999'
               ELSE ''
          END AS capital,
          savings.amount AS savings_amount,
          details.case_number AS case_number,
          oa.postcode AS postcode,
          applicants.date_of_birth AS date_of_birth,
          details.date_received AS date_received,
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
        JOINS
      end
    end
  end
end
