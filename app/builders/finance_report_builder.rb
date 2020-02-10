class FinanceReportBuilder
  require 'csv'

  FIELDS = {
    office: 'office',
    jurisdiction: 'jurisdiction',
    be_code: 'BEC',
    sop_code: 'SOP code',
    total_count: 'Total successful quantity',
    total_sum: 'Total successful amount',
    full_count: 'full remission quantity',
    full_sum: 'full remission amount',
    part_count: 'part remission quantity',
    part_sum: 'part remission amount',
    benefit_count: 'benefit basis quantity',
    benefit_sum: 'benefit basis amount',
    income_count: 'income basis quantity',
    income_sum: 'income basis amount',
    none_count: 'granted basis quantity',
    none_sum: 'granted basis amount'
  }.freeze

  def initialize(start_date, end_date, filters = {})
    @date_from = format_dates(start_date)
    @date_to = format_dates(end_date).end_of_day
    @filters = filters
  end

  def format_dates(date_attribute)
    DateTime.parse(date_attribute.values.join('/')).utc
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      meta_data.each do |meta|
        csv << meta
      end

      csv << ['']
      csv << FIELDS.values

      generate.each do |row|
        csv << FIELDS.keys.map { |attr| row.send(attr) }
      end
    end
  end

  private

  def meta_data
    period_selected = "#{@date_from.to_date}-#{@date_to.to_date}"
    run = Time.zone.now
    [
      ['Report Title:', 'Remissions Granted Report'],
      ['Criteria:', 'Date status changed to "successful"'],
      ['Period Selected:', period_selected],
      ['Run:', run]
    ]
  end

  def generate
    data = []
    distinct_offices_jurisdictions.each do |business_entity|
      data << Views::Reports::FinanceReportDataRow.new(business_entity, @date_from, @date_to)
    end
    data
  end

  def distinct_offices_jurisdictions
    list = offices_jurisdictions_query
    list = filtered_query(list)
    list.distinct { |s| s.values_at(:office, :jurisdiction) }
  end

  def offices_jurisdictions_query
    BusinessEntity.
      exclude_hq_teams.
      joins('LEFT JOIN applications ON business_entity_id = business_entities.id').
      where('decision_date BETWEEN :d1 AND :d2', d1: @date_from, d2: @date_to).
      where('applications.state = 3')
  end

  def filtered_query(list)
    return list if @filters.blank?
    list = list.where(be_code: be_code_filter) if be_code_filter
    list = list.where(jurisdiction_id: jurisdiction_filter) if jurisdiction_filter
    list = list.where('applications.application_type = ?', app_type_filter) if app_type_filter

    if refund_filter
      list = list.joins('LEFT JOIN details ON applications.id = details.application_id').
             where('details.refund = true')
    end
    list
  end

  def be_code_filter
    @filters[:be_code]
  end

  def jurisdiction_filter
    @filters[:jurisdiction_id]
  end

  def refund_filter
    @filters[:refund].to_i != 0
  end

  def app_type_filter
    @filters[:application_type]
  end
end
