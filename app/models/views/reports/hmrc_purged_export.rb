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
        return "no results" unless data.first
        CSV.generate do |csv|
          csv << keys
          data.each do |row|
            csv << process_row(row)
          end
        end
      end

      private

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def process_row(row)
        line = []
        line << row[0].to_fs(:db) # 'hmrc_checks.created_at',
        line << row[3] # office
        line << check_empty(row[4]) # be code
        line << row[5] # user
        line << check_empty(row[1].try(:to_fs, :db)) # purged_at
        line << row[2] # reference
        line << row[6] # dob
        line << date_range(row[7]) # date range
        line << hmrc_data(row)
        line.flatten
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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

      def check_empty(row)
        row.presence || 'N/A'
      end

      def date_range(value)
        return 'N/A' if value.blank? || value[:date_range].blank?
        "#{value[:date_range][:from]} to #{value[:date_range][:to]}"
      rescue NoMethodError
        'N/A'
      end

      def keys
        ['Date created', 'Office', 'BE code', 'Staff member', 'Date purged', 'HWF reference', 'Applicant DOB',
         'Date range HMRC data requested for', 'PAYE data', 'Child Tax Credit', 'Work Tax Credit']
      end

      def data
        @data ||= build_data
      end

      def build_data
        HmrcCheck.where('hmrc_checks.created_at between ? AND ?', @date_from, @date_to).
          order('hmrc_checks.created_at asc').includes(evidence_check: [:application]).
          includes(evidence_check: [{ application: [:applicant, :office, :user, :business_entity] }]).
          pluck('hmrc_checks.created_at', 'hmrc_checks.purged_at', 'applications.reference',
                'offices.name', 'business_entities.sop_code', 'users.name',
                'hmrc_checks.date_of_birth', 'hmrc_checks.request_params', 'hmrc_checks.income',
                'hmrc_checks.tax_credit')
      end

    end
  end
end
