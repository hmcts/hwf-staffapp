module Views
  module Reports
    # Power BI export 2
    #
    # Same fields as PowerBiNewExport's export2 (all states, including unlinked
    # online applications), but pulled on created_at instead of date_received and
    # for the whole of a single calendar month. Defaults to the previous month
    # (run in May it exports April), but any month can be passed in.
    class PowerBiExport2
      require 'fileutils'

      attr_reader :zipfile_path

      def initialize(month = Time.zone.today.prev_month)
        @export = PowerBiNewExport.new(month.beginning_of_month, month.end_of_month)
      end

      def to_zip
        @zipfile_path = @export.export2_by_created_at
      end

      def tidy_up
        FileUtils.rm_f(zipfile_path)
      end
    end
  end
end
