# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::PublicSubmissionData do
  let!(:online_application) { travel_to(8.days.ago) { create(:online_application, :completed, :with_reference) } }

  before do
    travel_to(8.days.ago) do
      create_list(:online_application, 3, :completed, :with_reference, convert_to_application: true)
      create(:application, :uncompleted, :with_office, state: :created, online_application: online_application, reference: online_application.reference)
    end
    travel_to(2.days.ago) do
      create_list(:online_application, 1, :completed, :with_reference, convert_to_application: true)
    end
  end

  subject(:data) { described_class.new }

  # #submission_all_time_total returns the expected count of processed online submissions, ignoring uncompleted conversions'
  it { expect(data.submission_all_time_total).to eq 4 }

  # #submission_all_time returns a collection of courts and a total count of the applications processed
  it { expect(data.submission_all_time.count).to eq 4 }

  # #submission_seven_day_total returns the expected count of processed online submissions in the last 7 days
  it { expect(data.submission_seven_day_total).to eq 1 }

  # #submission_seven_day returns a collection of courts and a count of the applications processed in the last 7 days
  it { expect(data.submission_seven_day.count).to eq 1 }

  # #submission_total_time_taken returns a collection of courts and an average of the time taken to process applications
  it { expect(data.submission_total_time_taken.count).to eq 4 }

  # #submission_seven_day_time_taken returns a collection of courts and an average of the time taken to process applications in the last 7 days
  it { expect(data.submission_seven_day_time_taken.count).to eq 1 }
end
