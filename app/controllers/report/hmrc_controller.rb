module Report
  class HmrcController < ReportsController
    before_action :authorize_hmrc_purged

    def show
      render 'reports/hmrc'
    end

    def data_export
      build_and_send_data
    rescue StandardError => e
      Sentry.with_scope do |scope|
        scope.set_tags(task: "hmrc_purged_export")
        Sentry.capture_message(e.message)
      end
      Rails.logger.debug { "Error in hmrc_purged_export export task: #{e.message}" }
      render 'reports/hmrc'
    end

    private

    def hmrc_purged_data
      @date_from = 1.year.ago.beginning_of_day
      @date_to = Time.zone.now
      Views::Reports::HmrcPurgedExport.new(@date_from, @date_to).to_csv
    end

    def authorize_hmrc_purged
      authorize :report, :hmrc_purged?
    end

    def build_and_send_data
      from = @date_from.to_date.to_fs(:iso8601)
      to = @date_to.to_date.to_fs(:iso8601)
      send_data hmrc_purged_data,
                filename: "help-with-fees-#{from}-to-#{to}-hmrc-data-purged-history.csv",
                type: 'text/csv',
                disposition: 'attachment'
    end

  end
end
