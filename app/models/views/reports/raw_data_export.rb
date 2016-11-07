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
        evidence_checked: 'evidence checked?'
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
          select(:id, :fee, :form_name, :probate, :refund, :application_type,
            :income, :children, :decision, :amount_to_pay, :decision_cost, :married).
          select(named_columns).
          joins(joins).
          joins(:applicant, :business_entity, detail: :jurisdiction).
          where("offices.name NOT IN ('Digital')").
          where(decision_date: @date_from..@date_to, state: Application.states[:processed])
      end

      def named_columns
        <<-COLUMNS
          offices.name AS name,
          details.emergency_reason IS NOT NULL AS emergency,
          jurisdictions.name AS jurisdiction,
          business_entities.code AS bec_code,
          CASE WHEN reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
          CASE WHEN de.id IS NULL THEN false ELSE true END AS granted,
          CASE WHEN ec.id IS NULL THEN false ELSE true END AS evidence_checked
        COLUMNS
      end

      def joins
        <<-JOINS
          LEFT OUTER JOIN offices ON offices.id = applications.office_id
          LEFT OUTER JOIN decision_overrides de ON de.application_id = applications.id
          LEFT OUTER JOIN evidence_checks ec ON ec.application_id = applications.id
        JOINS
      end
    end
  end
end
