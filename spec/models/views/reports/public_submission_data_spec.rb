# coding: utf-8
require 'rails_helper'

RSpec.describe Views::Reports::PublicSubmissionData do

  before do
    Timecop.freeze(8.days.ago) do
      create_list :online_application, 8, :completed, :with_reference, convert_to_application: true
    end
    Timecop.freeze(2.days.ago) do
      create_list :online_application, 2, :completed, :with_reference, convert_to_application: true
    end
  end

  subject(:data) { described_class.new }

  it 'returns the expected data' do
    # #submission_all_time_total returns the expected count of processed online submissions'
    expect(data.submission_all_time_total).to eq 10

    # #submission_all_time returns a collection of courts and a total count of the applications processed
    expect(data.submission_all_time.count).to eq 10

    # #submission_seven_day_total returns the expected count of processed online submissions in the last 7 days
    expect(data.submission_seven_day_total).to eq 2

    # #submission_seven_day returns a collection of courts and a count of the applications processed in the last 7 days
    expect(data.submission_seven_day.count).to eq 2

    # #submission_total_time_taken returns a collection of courts and an average of the time taken to process applications
    expect(data.submission_total_time_taken.count).to eq 10

    # #submission_seven_day_time_taken returns a collection of courts and an average of the time taken to process applications in the last 7 days
    expect(data.submission_seven_day_time_taken.count).to eq 2
  end
end
