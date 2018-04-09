class ProcessingPerformanceExport
  require 'csv'
  attr_reader :processed

  def initialize
    @from = DateTime.parse('March 1 2017 00:00')
    @to = DateTime.parse('February 28 2018 23:59')
    @application_state = 3
    @processed = processed_query
  end

  def processed_query
    Application.where(state: @application_state, created_at: @from..@to)
  end

  def export
    CSV.open("processing_performance_export.csv", "wb", {:force_quotes=>true}) do |csv|
      csv << headers
      preformated_data.each do |row|
        csv << row
      end
    end
  end

  private

  def preformated_data
    data = []
    @processed.each_with_index do |application, index|
      data[index] = []
      data[index] << application.reference
      data[index] << online_application_submitted(application)
      data[index] << application.created_at
      data[index] << application.completed_at
      data[index] << decision_time_in_minutes(application)
      data[index] << application_format(application)
      data[index] << application.office.name
      data[index] << application_outcome(application)
    end
    data
  end

  def online_application_submitted(application)
    (application.online_application) ? application.online_application.created_at : nil
  end

  def application_format(application)
    (application.online_application) ? 'digital' : 'paper'
  end

  def application_outcome(application)
    case application
    when 'full'
      'full payment'
    when 'part'
      'partial payment'
    else
      'no payment'
    end
  end

  def headers
    ['Application reference number',
     'Submission date (digital only)',
     'Created at',
     'Completed at',
     'Decision time in minutes',
     'Paper or digital application',
     'Processing office',
     'Outcome']
  end

  def decision_time_in_minutes(application)
    ((application.completed_at - application.created_at)/60).round(2)
  end
end