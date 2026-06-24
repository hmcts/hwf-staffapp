module Views
  module Reports
    # Power BI export 2
    #
    # Same fields as PowerBiNewExport's export2 (all states, including unlinked
    # online applications), but pulled on created_at instead of date_received and
    # fixed to the whole of the previous calendar month. Run in May it exports
    # April, run in March it exports February, and so on.
    class PowerBiExport2
      require 'fileutils'

      attr_reader :zipfile_path

      def initialize
        @export = PowerBiNewExport.new(previous_month.beginning_of_month, previous_month.end_of_month)
      end

      def to_zip
        @zipfile_path = @export.export2_by_created_at
      end

      def tidy_up
        FileUtils.rm_f(zipfile_path)
      end

      private

      def previous_month
        Time.zone.today.prev_month
      end
    end
  end
end
