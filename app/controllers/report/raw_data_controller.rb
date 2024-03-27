module Report
  class RawDataController < ReportsController

    def show
      authorize :report, :raw_data?
      @form = Forms::FinanceReport.new
      render "reports/raw_data"
    end

    def data_export
      authorize :report, :raw_data?
      @form = form
      if @form.valid?
        delay_job_export
      else
        render "reports/raw_data"
      end
    end

    private

    def delay_job_export
      from_date = date_from(report_params)
      to_date = date_to(report_params)
      user_id = current_user.id

      RawDataExportJob.perform_later(from: from_date, to: to_date, user_id: user_id)
    end

    # def extract_raw_data
    #   @raw_export = Views::Reports::RawDataExport.new(date_from(report_params), date_to(report_params))
    #   @raw_export.to_zip
    # rescue StandardError => e
    #   Sentry.with_scope do |scope|
    #     scope.set_tags(task: "raw_data_export")
    #     Sentry.capture_message(e.message)
    #   end
    #   Rails.logger.debug { "Error in raw_data export task: #{e.message}" }
    # end

  end
end
