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
        flash[:notice] = I18n.t('.forms/report/raw_data.notice')
        redirect_to reports_path
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

  end
end
