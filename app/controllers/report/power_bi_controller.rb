module Report
  class PowerBiController < ReportsController

    def index
      authorize :report, :power_bi?
      render 'reports/power_bi/index'
    end

    def show
      authorize :report, :power_bi?
      render 'reports/power_bi/show'
    end

    def data_export
      authorize :report, :power_bi?
      # Built in the background and emailed, as the export can outlast the request - see CHANGELOG.md
      PowerBiExportJob.perform_later(export_type: params[:export_type], month: selected_month,
                                     user_id: current_user.id)
      redirect_to report_power_bi_path, notice: t('forms/report/power_bi.notice')
    end

    private

    # Parse the chosen "YYYY-MM" month, falling back to the previous month.
    def selected_month
      Date.strptime(params[:month], '%Y-%m').beginning_of_month
    rescue ArgumentError, TypeError
      Time.zone.today.prev_month.beginning_of_month
    end

  end
end
