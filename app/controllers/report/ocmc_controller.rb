module Report
  class OcmcController < ReportsController
    before_action :authorise_ocmc_data

    def show
      @form = Forms::FinanceReport.new

      render 'reports/ocmc_report'
    end

    # rubocop:disable Metrics/MethodLength
    def data_export
      @form = form
      if @form.valid?
        if @form.all_offices || @form.all_datashare_offices
          delay_job_export
          flash[:notice] = I18n.t('.forms/report/ocmc.notice')
          redirect_to reports_path
        else
          build_and_return_data(extract_ocmc_data, export_file_prefix)
        end
      else
        render 'reports/ocmc_report'
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def extract_ocmc_data
      Views::Reports::HmrcOcmcDataExport.new(date_from(report_params), date_to(report_params), court_id).to_csv
    end

    def delay_job_export
      from_date = date_from(report_params)
      to_date = date_to(report_params)
      user_id = current_user.id
      all_offices = report_params[:all_offices]
      all_datashare_offices = report_params[:all_datashare_offices]

      OcmcExportJob.perform_later(from: from_date, to: to_date, court_id:, user_id:, all_offices:,
                                  all_datashare_offices:)
    end

    def authorise_ocmc_data
      authorize :report, :ocmc_report?
    end

    def court_id
      report_params[:entity_code]
    end

    def export_file_prefix
      "help-with-fees-#{court_id}-applications-by-court-extract"
    end

  end
end
