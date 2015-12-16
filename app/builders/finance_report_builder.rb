class FinanceReportBuilder
  require 'csv'

  def initialize(start_date, end_date)
    @date_from = Date.parse(start_date.to_s)
    @date_to = Date.parse(end_date.to_s)
  end

  def to_csv
    attributes = %w[office jurisdiction total_count total_sum
                    full_count full_sum part_count part_sum
                    benefit_count benefit_sum income_count income_sum]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      generate.each do |row|
        csv << attributes.map { |attr| row.send(attr) }
      end
    end
  end

  def generate
    data = []
    distinct_offices_jurisdictions.each do |business_entity|
      data << Views::Reports::FinanceReportDataRow.new(business_entity, @date_from, @date_to)
    end
    data
  end

  private

  def distinct_offices_jurisdictions
    BusinessEntity.
      joins('LEFT OUTER JOIN applications ON business_entity_id = business_entities.id').
      where('decision_date BETWEEN :d1 AND :d2', d1: @date_from, d2: @date_to).
      where('applications.state = 3').uniq { |s| s.values_at(:office, :jurisdiction) }
  end
end
