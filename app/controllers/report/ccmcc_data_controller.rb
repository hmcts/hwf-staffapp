module Report
  class CcmccDataController < ReportsController
    before_action :authorise_ccmcc_data

    def show
      @form = Forms::FinanceReport.new
      render 'reports/ccmcc_data'
    end

    def data_export
      @form = form
      if @form.valid?
        build_and_return_data(extract_ccmcc_data, 'help-with-fees-ccmcc-extract')
      else
        render 'reports/ccmcc_data'
      end
    end

    private

    def extract_ccmcc_data
      Views::Reports::CCMCCDataExport.new(date_from(report_params), date_to(report_params)).to_csv
    end

    def authorise_ccmcc_data
      authorize :report, :ccmcc_data?
    end

  end
end
