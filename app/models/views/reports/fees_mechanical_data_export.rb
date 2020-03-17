module Views
  module Reports
    class FeesMechanicalDataExport
      require 'csv'

      FM_OFFICE_CODE = 'IE413'.freeze

      FIELDS = {
        reference: 'reference number',
        created_at: 'created at',
        fee: 'fee',
        amount_to_pay: 'estimated applicant pays',
        estimated_cost: 'estimated cost',
        outcome: 'outcome',
        final_amount_to_pay: 'final applicant pays',
        decision_cost: 'departmental cost',
        name: 'processed by',
        ev_id: 'evidence check',
        check_type: 'evidence checked type',
        checks_annotation: 'fees_mechanical annotations',
        refund: 'refund',
        state: 'application state'
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

      def total_count
        data.size
      end

      private

      def data
        @data ||= build_data
      end

      def build_data
        Application.left_outer_joins(:evidence_check).left_outer_joins(:part_payment).distinct.
          select('applications.reference', 'applications.created_at', 'details.fee',
                 'applications.outcome', 'applications.decision', 'applications.amount_to_pay',
                 'applications.decision_cost', 'users.name', 'evidence_checks.id as ev_id',
                 'evidence_checks.amount_to_pay as ev_amount_to_pay',
                 'part_payments.outcome as pp_outcome',
                 'evidence_checks.check_type', 'evidence_checks.checks_annotation',
                 'details.refund', 'applications.state').
          joins(:office, :user, :detail).where(created_at: @date_from..@date_to).
          where("offices.entity_code = ?", fees_mechanical_code).where(application_type: 'income')
      end

      # rubocop:disable Metrics/MethodLength
      def process_row(row, attr)
        if attr == :ev_id
          ev_check(row)
        elsif attr == :amount_to_pay
          row.amount_to_pay.to_f
        elsif attr == :estimated_cost
          decision_cost_calculation(row)
        elsif attr == :final_amount_to_pay
          final_amount_to_pay(row)
        else
          row.send(attr)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def ev_check(row)
        row.ev_id.blank? ? 'No' : 'Yes'
      end

      def fees_mechanical_code
        FM_OFFICE_CODE
      end

      def decision_cost_calculation(row)
        (row.fee - row.amount_to_pay.to_f) || 0.0
      end

      def final_amount_to_pay(row)
        return row.fee if row.try(:pp_outcome).present? && row.pp_outcome != 'part'
        row.try(:ev_amount_to_pay) || row.amount_to_pay
      end

    end
  end
end
