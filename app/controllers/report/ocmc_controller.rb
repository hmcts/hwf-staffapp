module Report
  class OcmcController < ReportsController
    before_action :authorise_ocmc_data

    def show
      @form = Forms::FinanceReport.new
      render 'reports/ocmc_report'
    end

    def data_export
      @form = form
      if @form.valid?
        build_and_return_data(extract_ocmc_data,
                              export_file_prefix)
      else
        render 'reports/ocmc_report'
      end
    end

    private

    def extract_ocmc_data
      Views::Reports::HmrcOcmcDataExport.new(date_from(report_params), date_to(report_params), court_id).to_csv
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
