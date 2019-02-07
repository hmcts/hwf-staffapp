class FinanceTransactionalReportBuilder
  require 'csv'

  CSV_FIELDS = {
    month_year: 'Month-Year',
    entity_code: 'Entity Code',
    office_name: 'Office Name',
    jurisdiction_name: 'Jurisdiction Name',
    remission_amount: 'Remission Amount',
    refund: 'Refund',
    decision: 'Decision',
    application_type: 'Application Type',
    application_id: 'Application ID',
    reference: 'HwF Reference',
    decision_date: 'Decision Date',
    fee: 'Fee Amount'
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
      csv << CSV_FIELDS.values

      generate.each do |row|
        csv << CSV_FIELDS.keys.map { |attr| row.send(attr) }
      end
    end
  end

  private

  def meta_data
    period_selected = "#{@date_from.to_date}-#{@date_to.to_date}"
    run = Time.zone.now
    [
      ['Report Title:', 'Finance Transactional Report'],
      ['Criteria:', 'Date status changed to "successful"'],
      ['Period Selected:', period_selected],
      ['Run:', run]
    ]
  end

  def generate
    data = []
    applications.each do |application|
      data << Views::Reports::FinanceTransactionalReportDataRow.new(application)
    end
    data
  end

  def applications
    Application.
      includes(:detail).
      includes(office: :jurisdictions).
      includes(:business_entity).
      where(decision: ['part', 'full']).
      where(decision_date: @date_from..@date_to).
      where(state: Application.states[:processed]).
      order('decision_date::timestamp::date ASC').
      order('offices.entity_code ASC')
  end
end
