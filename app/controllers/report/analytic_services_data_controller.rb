module Report
  class AnalyticServicesDataController < ReportsController
    before_action :authorise_analytic_services_data

    def show
      @form = Forms::FinanceReport.new
      render 'reports/analytic_services_data'
    end

    def data_export
      @form = form
      if @form.valid?
        build_and_return_data(extract_analytic_services_data,
                              'help-with-fees-analytic-services-extract')
      else
        render 'reports/analytic_services_data'
      end
    end

    private

    def extract_analytic_services_data
      Views::Reports::AnalyticServicesDataExport.new(date_from(report_params),
                                                   date_to(report_params), entity_code).to_csv
    end

    def authorise_analytic_services_data
      authorize :report, :analytic_services_data?
    end

    def entity_code
      report_params[:entity_code]
    end

  end
end
