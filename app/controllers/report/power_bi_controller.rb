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
      power_bi = power_bi_export
      power_bi.to_zip
      power_bi.zipfile_path
    rescue StandardError => e
      Sentry.with_scope do |scope|
        scope.set_tags(task: "power_bi_export")
        Sentry.capture_message(e.message)
      end
      Rails.logger.debug { "Error in power_bi export task: #{e.message}" }
    end

    def power_bi_export
      case params[:export_type]
      when '2' then Views::Reports::PowerBiExport2.new
      when '3' then Views::Reports::PowerBiExport3.new
      else Views::Reports::PowerBiExport1.new
      end
    end

  end
end
