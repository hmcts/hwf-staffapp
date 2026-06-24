module Views
  module Reports
    # Power BI export 1
    #
    # Produces the same data as the raw data extract (RawDataExport) - same
    # fields, SQL and formatting - but for the whole of a single calendar month.
    # Defaults to the previous month (run in May it exports April), but any month
    # can be passed in.
    class PowerBiExport1 < RawDataExport
      def initialize(month = Time.zone.today.prev_month)
        start_date = date_hash(month.beginning_of_month)
        end_date = date_hash(month.end_of_month)

        super(start_date, end_date)

        @csv_file_name = "power_bi_export_1-#{start_date.values.join('-')}-#{end_date.values.join('-')}.csv"
        @zipfile_path = "tmp/#{@csv_file_name}.zip"
      end

      private

      def date_hash(date)
        { day: date.day, month: date.month, year: date.year }
      end
    end
  end
end
