class FinanceReportBuilder
  require 'csv'

  HEADERS = [
    'office', 'jurisdiction', 'BEC',
    'Total successful quantity', 'Total successful amount',
    'full remission quantity', 'full remission amount',
    'part remission quantity', 'part remission amount',
    'benefit basis quantity', 'benefit basis amount',
    'income basis quantity', 'income basis amount'
  ].freeze

  ATTRIBUTES = %w[office jurisdiction be_code total_count total_sum
                  full_count full_sum part_count part_sum
                  benefit_count benefit_sum income_count income_sum].freeze

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
      csv << HEADERS

      generate.each do |row|
        csv << ATTRIBUTES.map { |attr| row.send(attr) }
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
      joins('LEFT OUTER JOIN applications ON business_entity_id = business_entities.id').
      where('decision_date BETWEEN :d1 AND :d2', d1: @date_from, d2: @date_to).
      where('applications.state = 3').uniq { |s| s.values_at(:office, :jurisdiction) }
  end
end
