module Report
  class ApplicationsByCourtController < ReportsController
    before_action :authorise_applications_by_court_data

    def show
      @form = Forms::FinanceReport.new

      render 'reports/applications_by_court_report'
    end

    # rubocop:disable Metrics/MethodLength
    def data_export
      @form = form
      if @form.valid?
        if @form.all_offices
          delay_job_export

          flash[:notice] = flash_message

          redirect_to reports_path
        else
          build_and_return_data(extract_applications_by_court_data, export_file_prefix)
        end
      else
        render 'reports/applications_by_court_report'
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def extract_applications_by_court_data
      Views::Reports::ApplicationsByCourtExport.new(date_from(report_params), date_to(report_params), court_id).to_csv
    end

    def delay_job_export
      from_date = date_from(report_params)
      to_date = date_to(report_params)
      user_id = current_user.id
      all_offices = report_params[:all_offices]

      ApplicationsByCourtExportJob.perform_later(from: from_date, to: to_date, court_id:, user_id:, all_offices:)
    end

    def authorise_applications_by_court_data
      authorize :report, :applications_by_court_report?
    end

    def court_id
      report_params[:entity_code]
    end

    def export_file_prefix
      "help-with-fees-#{court_id}-applications-by-court-extract"
    end

    def flash_message
      I18n.t('.forms/report/applications_by_court.notice')
    end
  end
end
