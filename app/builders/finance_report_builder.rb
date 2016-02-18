class FinanceReportBuilder
  require 'csv'

  SUB_HEADERS = ['', '', '', 'successful remissions', '', 'full remissions', '',
                 'part remissions', '', 'Benefit applications', '',
                 'Income applications', '']

  HEADERS = %w[office jurisdiction BEC count sum count sum count sum count sum count sum]

  ATTRIBUTES = %w[office jurisdiction be_code total_count total_sum
                  full_count full_sum part_count part_sum
                  benefit_count benefit_sum income_count income_sum]

  def initialize(start_date, end_date)
    @date_from = Date.parse(start_date.to_s).to_datetime
    end_date = Date.parse(end_date.to_s)
    @date_to = DateTime.new(end_date.year, end_date.month, end_date.day, 23, 59, 59, 'GMT')
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << SUB_HEADERS
      csv << HEADERS

      generate.each do |row|
        csv << ATTRIBUTES.map { |attr| row.send(attr) }
      end
    end
  end

  private

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
