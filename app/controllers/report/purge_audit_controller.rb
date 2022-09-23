module Report
  class PurgeAuditController < ReportsController
    before_action :authorize_purge_audit

    def show
      @form = Forms::FinanceReport.new
      render 'reports/purged_audit'
    end

    def data_export
      @form = form

      if @form.valid?
        build_and_return_data(personal_purged_data, 'help-with-fees-personal-data-purged-history')
      else
        render :purge_audit
      end
    end

    private

    def personal_purged_data
      Views::Reports::AuditPersonalDataReport.new(date_from(report_params), date_to(report_params)).to_csv
    end

    def authorize_purge_audit
      authorize :report, :purge_audit?
    end
  end
end
