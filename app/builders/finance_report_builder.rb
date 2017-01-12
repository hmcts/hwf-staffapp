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

  def initialize(start_date, end_date)
    @date_from = DateTime.parse(start_date.to_s).utc
    @date_to = DateTime.parse(end_date.to_s).utc.end_of_day
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
    BusinessEntity.
      exclude_hq_teams.
      joins('LEFT JOIN applications ON business_entity_id = business_entities.id').
      where('decision_date BETWEEN :d1 AND :d2', d1: @date_from, d2: @date_to).
      where('applications.state = 3').uniq { |s| s.values_at(:office, :jurisdiction) }
  end
end
