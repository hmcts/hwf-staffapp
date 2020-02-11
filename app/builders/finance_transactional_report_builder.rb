class FinanceTransactionalReportBuilder
  require 'csv'

  CSV_FIELDS = {
    month_year: 'Month-Year',
    entity_code: 'BEC',
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
    filtered_query(report_default_query)
  end

  def report_default_query
    Application.
      includes(:detail).
      includes(:office).
      includes(:business_entity).
      includes(business_entity: :jurisdiction).
      where(decision: ['part', 'full']).
      where(decision_date: @date_from..@date_to).
      where(state: Application.states[:processed]).
      order(Arel.sql('decision_date::timestamp::date ASC')).
      order(Arel.sql('business_entities.be_code ASC'))
  end

  def filtered_query(list)
    list = list.where(business_entity_id: be_code_filter) if be_code_filter
    list = list.where('details.refund = true') if refund_filter
    list = list.where(application_type: app_type_filter) if app_type_filter
    if jurisdiction_filter
      list = list.where('business_entities.jurisdiction_id = ?', jurisdiction_filter)
    end
    list
  end

  def be_code_filter
    if @filters[:be_code]
      BusinessEntity.where(be_code: @filters[:be_code]).map(&:id)
    end
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
