class FinanceTransactionalReportBuilder < ReportBase

  CSV_FIELDS = {
    month_year: 'Month-Year',
    sop_code: 'SOP',
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

    @csv_file_name = "finance-transactional-#{start_date.values.join('-')}-#{end_date.values.join('-')}.csv"
    @zipfile_path = "tmp/#{@csv_file_name}.zip"
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      meta_data.each do |meta|
        csv << meta
      end

      csv << ['']
      csv << CSV_FIELDS.values

      generate.each do |row|
        csv << CSV_FIELDS.keys.map { |attr| process_row(row, attr) }
      end
    end
  end

  def process_row(row, attr)
    if attr == :decision_date
      row.send(attr).to_fs(:default) if row.send(attr).present?
    else
      row.send(attr)
    end
  end

  private

  def meta_data
    period_selected = "#{@date_from.to_date.to_fs(:default)}-#{@date_to.to_date.to_fs(:default)}"
    run = Time.zone.now
    [
      ['Report Title:', 'Finance Transactional Report'],
      ['Criteria:', 'Date status changed to "successful"'],
      ['Period Selected:', period_selected],
      ['Run:', run.to_fs(:default)]
    ]
  end

  def generate
    applications.map do |application|
      Views::Reports::FinanceTransactionalReportDataRow.new(application)
    end
  end

  def applications
    filtered_query(report_default_query)
  end

  def report_default_query
    Application.
      includes(:detail, :office, :business_entity).
      includes(business_entity: :jurisdiction).
      where(decision: ['part', 'full']).
      where(decision_date: @date_from..@date_to).
      where(state: Application.states[:processed]).
      where("offices.name NOT IN ('Digital')").
      order(Arel.sql('decision_date::timestamp::date ASC')).
      order(Arel.sql('business_entities.sop_code ASC'))
  end

  def filtered_query(list)
    list = list.where(business_entity_id: sop_code_filter) if sop_code_filter
    list = list.where('details.refund = true') if refund_filter
    list = list.where(application_type: app_type_filter) if app_type_filter
    if jurisdiction_filter
      list = list.where(business_entities: { jurisdiction_id: jurisdiction_filter })
    end
    list
  end

  def sop_code_filter
    if @filters[:sop_code]
      BusinessEntity.where(sop_code: @filters[:sop_code]).map(&:id)
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
