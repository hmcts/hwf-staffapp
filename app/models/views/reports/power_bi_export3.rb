module Views
  module Reports
    # Power BI export 3
    #
    # Replication of the applications by court export (ApplicationsByCourtExport),
    # across all offices, for the whole of a single calendar month (by
    # created_at). Defaults to the previous month (run in May it exports April),
    # but any month can be passed in. Uses the court export's columns as they are.
    class PowerBiExport3 < ApplicationsByCourtExport
      require 'fileutils'

      def initialize(month = Time.zone.today.prev_month)
        start_date = date_hash(month.beginning_of_month)
        end_date = date_hash(month.end_of_month)

        super(start_date, end_date, nil, all_offices: true)

        @csv_file_name = "power_bi_export_3-#{start_date.values.join('-')}-#{end_date.values.join('-')}.csv"
        @zipfile_path = "tmp/#{@csv_file_name}.zip"
      end

      def tidy_up
        FileUtils.rm_f(zipfile_path)
      end

      private

      def date_hash(date)
        { day: date.day, month: date.month, year: date.year }
      end
    end
  end
end
