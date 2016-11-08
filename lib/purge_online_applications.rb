class PurgeOnlineApplications
  attr_reader :oldest_retention_date

  def initialize
    @oldest_retention_date = Date.current - 4.months
  end

  def affected_records
    data
  end

  def now!
    data.destroy_all
  end

  private

  def data
    @data ||= build_data_set
  end

  def build_data_set
    OnlineApplication.
      joins('LEFT JOIN applications a ON a.online_application_id = online_applications.id').
      where('online_applications.created_at < ?', @oldest_retention_date).
      where('a.online_application_id IS NULL')
  end
end
