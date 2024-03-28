module Report
  class RawDigitalDataController < ReportsController

    def show
      authorize :report, :raw_data?
      @form = Forms::FinanceReport.new
      render "reports/raw_digital_data"
    end

    def data_export
      authorize :report, :raw_data?
      @form = form
      if @form.valid?
        extract_raw_data
        send_file @raw_export.zipfile_path
      else
        render "reports/raw_digital_data"
      end
    end

    private

    def extract_raw_data
      @raw_export = Views::Reports::RawDigitalDataExport.new(date_from(report_params), date_to(report_params))
      @raw_export.to_zip
    rescue StandardError => e
      Sentry.with_scope do |scope|
        scope.set_tags(task: "raw_digital_data_export")
        Sentry.capture_message(e.message)
      end
      Rails.logger.debug { "Error in raw_data export task: #{e.message}" }
    end

  end
end
