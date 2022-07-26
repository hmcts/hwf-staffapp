module Views
  module Reports
    class HmrcPurgedExport
      require 'csv'

      def initialize(start_date, end_date)
        @date_from = start_date
        @date_to = end_date
      end

      def format_dates(date_attribute)
        DateTime.parse(date_attribute.values.join('/')).utc
      end

      def to_csv
        return "no resutls" unless data.first
        CSV.generate do |csv|
          csv << keys
          data.each do |row|
            csv << process_row(row)
          end
        end
      end

      private

      # rubocop:disable Metrics/AbcSize
      def process_row(row)
        line = []
        line << row[0] # 'hmrc_checks.created_at',
        line << row[1] # purged_at
        line << row[2] # reference
        line << "#{row[3]} #{row[4]}" # name
        line << row[5] # dob
        line << row[6] # ni number
        line << date_range(row[7]) # date range
        line << hmrc_data(row)
        line.flatten
      end
      # rubocop:enable Metrics/AbcSize

      def hmrc_data(row)
        hmrc = []
        hmrc << hmrc_value(row[8], :income) # paye
        hmrc << hmrc_value(row[9], :child) # child tax
        hmrc << hmrc_value(row[9], :work) # work tax
        hmrc
      end

      def hmrc_value(value, key)
        case key
        when :income
          data_value = value
        when :child, :work
          data_value = value[key]
        end

        data_value.blank? ? 'empty' : 'present'
      rescue NoMethodError
        'empty'
      end

      def date_range(value)
        return nil if value.blank? || value[:date_range].blank?
        "#{value[:date_range][:from]} to #{value[:date_range][:to]}"
      rescue NoMethodError
        nil
      end

      def keys
        ['Date created', 'Date purged', 'HWF reference', 'Applicant name', 'Applicant DOB', 'Applicant NI number',
         'Date range HMRC data requested for', 'PAYE data', 'Child Tax Credit', 'Work Tax Credit']
      end

      def data
        @data ||= build_data
      end

      def build_data
        HmrcCheck.where('hmrc_checks.created_at between ? AND ?', @date_from, @date_to).
          order('hmrc_checks.created_at asc').includes(evidence_check: [:application]).
          includes(evidence_check: [application: [:applicant]]).
          pluck('hmrc_checks.created_at', 'hmrc_checks.purged_at', 'applications.reference',
                'applicants.first_name', 'applicants.last_name', 'hmrc_checks.date_of_birth',
                'hmrc_checks.ni_number', 'hmrc_checks.request_params', 'hmrc_checks.income', 'hmrc_checks.tax_credit')
      end

    end
  end
end
