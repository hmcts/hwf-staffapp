module Views
  module Reports
    # Power BI export 1
    #
    # Produces the same data as the raw data extract (RawDataExport) - same
    # fields, SQL and formatting - but for a fixed time frame: the whole of the
    # previous calendar month. Run in May it exports April, run in March it
    # exports February, and so on.
    class PowerBiExport1 < RawDataExport
      def initialize
        start_date = date_hash(previous_month.beginning_of_month)
        end_date = date_hash(previous_month.end_of_month)

        super(start_date, end_date)

        @csv_file_name = "power_bi_export_1-#{start_date.values.join('-')}-#{end_date.values.join('-')}.csv"
        @zipfile_path = "tmp/#{@csv_file_name}.zip"
      end

      private

      def previous_month
        Time.zone.today.prev_month
      end

      def date_hash(date)
        { day: date.day, month: date.month, year: date.year }
      end
    end
  end
end
