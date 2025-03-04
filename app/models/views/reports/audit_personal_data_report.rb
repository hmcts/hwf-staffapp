module Views
  module Reports
    class AuditPersonalDataReport
      require 'csv'

      def initialize(start_date, end_date)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date)
      end

      def format_dates(date_attribute)
        DateTime.parse(date_attribute.values.join('/')).utc
      end

      def to_csv
        return "no results" unless data.first
        CSV.generate do |csv|
          csv << keys
          data.each do |row|
            csv << process_row(row)
          end
        end
      end

      private

      def process_row(row)
        row.enum_for(:each_with_index).map do |record, index|
          if index == 1
            record.presence || 'N/A'
          else
            record || 'purged'
          end
        end
      end

      def keys
        ['Date data purged', 'HwF reference', 'deceased_name', 'case_number', 'ho_number', 'ni_number', 'title',
         'first_name', 'last_name', 'address', 'email_address', 'phone']
      end

      def data
        @data ||= build_data
      end

      def build_data
        Application.with_deleted.where(purged: true).where('applications.purged_at between ? AND ?', @date_from,
                                                           @date_to).order('applications.purged_at ASC').
          includes(:detail, :applicant, :online_application).
          pluck('applications.purged_at', 'applications.reference',
                'details.deceased_name', 'details.case_number', 'applicants.ho_number', 'applicants.ni_number',
                'applicants.title', 'applicants.first_name', 'applicants.last_name',
                'online_applications.email_address', 'online_applications.email_address', 'online_applications.phone')
      end

    end
  end
end
