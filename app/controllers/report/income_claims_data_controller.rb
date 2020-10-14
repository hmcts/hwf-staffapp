module Report
  class IncomeClaimsDataController < ReportsController
    before_action :authorise_income_claims_data

    def show
      @form = Forms::FinanceReport.new
      render 'reports/income_claims_data'
    end

    def data_export
      @form = form
      if @form.valid?
        build_and_return_data(extract_income_claims_data,
                              export_file_prefix)
      else
        render 'reports/income_claims_data'
      end
    end

    private

    def extract_income_claims_data
      Views::Reports::IncomeClaimsDataExport.new(date_from(report_params),
                                                 date_to(report_params), entity_code).to_csv
    end

    def authorise_income_claims_data
      authorize :report, :income_claims_data?
    end

    def entity_code
      report_params[:entity_code]
    end

    def export_file_prefix
      postfix = Views::Reports::IncomeClaimsDataExport::OFFICE_POSTFIX[entity_code]
      "help-with-fees-#{postfix}-data-extract"
    end

  end
end
