module PowerBiHelper
  # The last 12 completed calendar months, most recent (last month) first,
  # as [label, value] pairs for a select - e.g. ['April 2026', '2026-04'].
  def power_bi_month_options
    last_month = Time.zone.today.prev_month.beginning_of_month
    (0..11).map do |months_back|
      month = last_month.months_ago(months_back)
      [month.strftime('%B %Y'), month.strftime('%Y-%m')]
    end
  end

  # Pre-selected value for the month dropdown: the previous calendar month.
  def power_bi_default_month
    Time.zone.today.prev_month.strftime('%Y-%m')
  end
end
