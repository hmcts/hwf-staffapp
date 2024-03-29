module Report
  class PowerBiController < ReportsController

    def show
      authorize :report, :power_bi?
      render 'reports/power_bi'
    end

    def data_export
      authorize :report, :power_bi?
      send_file power_bi_data_file
    end

    private

    def power_bi_data_file
      power_bi = Views::Reports::PowerBiExport.new
      power_bi.zipfile_path
    rescue StandardError => e
      Sentry.with_scope do |scope|
        scope.set_tags(task: "power_bi_export")
        Sentry.capture_message(e.message)
      end
      Rails.logger.debug { "Error in power_bi export task: #{e.message}" }
    end

  end
end
