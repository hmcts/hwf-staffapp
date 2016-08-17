module Views
  module Reports
    class RawDataExport
      require 'csv'

      HEADERS = ['id', 'office', 'jurisdiction', 'fee', 'application type',
                 'decision', 'applicant pays', 'departmental cost'].freeze
      ATTRIBUTES = %w[id office jurisdiction fee application_type
                      decision amount_to_pay decision_cost].freeze

      def initialize(date_from, date_to)
        @date_from = date_from
        @date_to = date_to
      end

      def to_csv
        CSV.generate do |csv|
          csv << HEADERS

          data.each do |row|
            csv << ATTRIBUTES.map { |attr| convert_data_row(row)[attr.to_sym] }
          end
        end
      end

      def total_count
        data.count
      end

      private

      def data
        @data ||= build_data
      end

      def build_data
        Application.
          joins(:detail).
          joins(:business_entity).
          joins('LEFT OUTER JOIN offices ON offices.id = applications.office_id').
          where("offices.name NOT IN ('Digital')").
          where(decision_date: @date_from..@date_to).
          where(state: Application.states[:processed])
      end

      def convert_data_row(application)
        {
          id: application.id,
          office: application.office.name,
          jurisdiction: application.business_entity.jurisdiction.name,
          fee: application.detail.fee,
          application_type: application.application_type,
          decision: application.decision,
          amount_to_pay: application.amount_to_pay ||= 0,
          decision_cost: application.decision_cost
        }
      end
    end
  end
end
