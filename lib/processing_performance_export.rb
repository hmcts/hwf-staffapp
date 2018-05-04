class ProcessingPerformanceExport
  require 'csv'
  include ActionView::Helpers::DateHelper
  attr_reader :processed_data, :preformated_data

  HEADERS = ['Application reference number', 'Submission date (digital only)',
             'Date received (paper only)', 'Created at', 'Completed at',
             'Date Processed', 'Decision time in minutes',
             'Processing time in minutes', 'Processing time in words',
             'Paper or digital application', 'Processing office',
             'Outcome', 'Applicaion status', 'Application type',
             'Evidence check required'].freeze

  def initialize(date_from = nil, date_to = nil)
    @from = date_from
    @to = date_to
    check_date_range
  end

  def process_query
    @processed_data = Application.where(
      created_at: @from..@to
    ).where.not(state: 4).order('created_at asc')
  end

  def export
    process_query
    preformate_data
  end

  def to_csv
    CSV.open("processing_performance_export.csv", "wb", force_quotes: true) do |csv|
      csv << ProcessingPerformanceExport::HEADERS
      @preformated_data.each do |row|
        csv << row
      end
    end
  end

  private

  def check_date_range
    return if @from.respond_to?(:strftime) &&
              @to.respond_to?(:strftime)
    @from = DateTime.parse('May 1 2017 00:00').utc
    @to = DateTime.parse('April 30 2018 23:59').utc
  end

  # rubocop:disable all
  def preformate_data
    @preformated_data = []
    @processed_data.each_with_index do |application, index|
      @preformated_data[index] = []
      @preformated_data[index] << application.reference
      @preformated_data[index] << online_application_submitted(application)
      @preformated_data[index] << paper_application_received(application)
      @preformated_data[index] << application.created_at
      @preformated_data[index] << application.completed_at
      @preformated_data[index] << application.updated_at
      @preformated_data[index] << decision_time_in_minutes(application)
      @preformated_data[index] << process_time_in_minutes(application)
      @preformated_data[index] << process_time_in_words(application)
      @preformated_data[index] << application_format(application)
      @preformated_data[index] << application.office.name
      @preformated_data[index] << application_outcome(application)
      @preformated_data[index] << application.state
      @preformated_data[index] << application.application_type
      @preformated_data[index] << evidence_check_required(application)
    end
  end
  # rubocop:enable all

  def online_application_submitted(application)
    application.online_application ? application.online_application.created_at : nil
  end

  def paper_application_received(application)
    application.online_application ? nil : application.detail.date_received
  end

  def application_format(application)
    application.online_application ? 'digital' : 'paper'
  end

  def application_outcome(application)
    case application.outcome
    when 'full'
      'full payment'
    when 'part'
      'partial payment'
    else
      'no payment'
    end
  end

  def decision_time_in_minutes(application)
    ((application.completed_at - application.created_at) / 60).round(2)
  rescue NoMethodError
    return nil
  end

  def process_time_in_minutes(application)
    return nil if application.state != 'processed'
    ((application.updated_at - application.created_at) / 60).round(2)
  rescue NoMethodError
    return nil
  end

  def process_time_in_words(application)
    return nil if application.state != 'processed'
    distance_of_time_in_words(application.updated_at, application.created_at, include_seconds: true)
  rescue NoMethodError
    return nil
  end

  def evidence_check_required(application)
    application.evidence_check.present? ? 'Yes' : 'No'
  end
end
