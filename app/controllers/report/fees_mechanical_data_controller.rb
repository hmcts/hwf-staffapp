module Report
  class FeesMechanicalDataController < ReportsController
    before_action :authorise_fees_mechanical_data

    def show
      @form = Forms::FinanceReport.new
      render 'reports/fees_mechanical_data'
    end

    def data_export
      @form = form
      if @form.valid?
        build_and_return_data(extract_fees_mechanical_data,
                              'help-with-fees-fees_mechanical-extract')
      else
        render 'reports/fees_mechanical_data'
      end
    end

    private

    def extract_fees_mechanical_data
      Views::Reports::FeesMechanicalDataExport.new(date_from(report_params),
                                                   date_to(report_params)).to_csv
    end

    def authorise_fees_mechanical_data
      authorize :report, :fees_mechanical_data?
    end

  end
end
