module PowerBiHelper
  # The available exports, keyed by the export_type used in the route/params.
  POWER_BI_EXPORTS = {
    '1' => 'Raw data export for dashboard reporting',
    '2' => 'Raw data export (all processing states) for dashboard reporting',
    '3' => 'Applications by court export (all processing states) for dashboard reporting'
  }.freeze

  EXPORT_NUMBER_WORDS = { '1' => 'one', '2' => 'two', '3' => 'three' }.freeze

  def power_bi_export_title(export_type)
    "Power BI extract #{EXPORT_NUMBER_WORDS.fetch(export_type, export_type)}"
  end

  def power_bi_export_description(export_type)
    POWER_BI_EXPORTS[export_type]
  end

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
