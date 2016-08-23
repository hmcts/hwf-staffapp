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
        decision_cost: 'departmental cost'
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
          select(:id, 'offices.name', :fee, :form_name, :probate, :refund, :application_type,
            :income, :children, :decision, :amount_to_pay, :decision_cost, :married).
          select('details.emergency_reason IS NOT NULL AS emergency').
          select('jurisdictions.name AS jurisdiction').
          select('business_entities.code AS bec_code').
          joins('LEFT OUTER JOIN offices ON offices.id = applications.office_id').
          joins(:applicant, :business_entity, detail: :jurisdiction).
          where("offices.name NOT IN ('Digital')").
          where(decision_date: @date_from..@date_to, state: Application.states[:processed])
      end
    end
  end
end
