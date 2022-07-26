module Report
  class HmrcController < ReportsController
    before_action :authorize_hmrc_purged

    def show
      render 'reports/hmrc'
    end

    def data_export
      build_and_send_data
    rescue StandardError => e
      Raven.tags_context(task: "hmrc_purged_export") do
        Raven.capture_message(e.message)
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
      send_data hmrc_purged_data,
                filename: "help-with-fees-#{@date_from.to_date}-to-#{@date_to.to_date}-hmrc-data-purged-history.csv",
                type: 'text/csv',
                disposition: 'attachment'
    end

  end
end
