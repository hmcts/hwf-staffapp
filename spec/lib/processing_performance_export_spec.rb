require 'rails_helper'

RSpec.describe ProcessingPerformanceExport do

  subject(:processing_perfomance_export) do
    described_class.new(Time.zone.today.beginning_of_day, Time.zone.today.end_of_day)
  end
  let(:online_application) { create :online_application_with_all_details }

  let(:application1) do
    create :application_full_remission, :with_office, :processed_state,
      online_application: online_application,
      created_at: 100.minutes.ago,
      completed_at: 90.minutes.ago,
      updated_at: 10.minutes.ago
  end
  let(:application2) do
    create :application_full_remission, :with_office, :processed_state,
      created_at: 30.minutes.ago,
      completed_at: 28.minutes.ago,
      updated_at: 1.minute.ago
  end

  let(:application3) { create :application_full_remission, :waiting_for_evidence_state }

  describe 'export data' do
    before do
      application1
      application2
      application3
    end
    let(:data) do
      processing_perfomance_export.export
      processing_perfomance_export.preformated_data
    end

    it "includes processed applications" do
      expect(data.count).to be(2)
    end

    context 'online_application' do
      let(:line) { data[0] }

      it 'Application reference number' do
        expect(line[0]).to eql(application1.reference)
      end

      it 'Submission date (digital only)' do
        expect(line[1]).to eql(online_application.created_at)
      end

      it 'Date received (paper only)' do
        expect(line[2]).to be(nil)
      end

      it 'Created at' do
        expect(line[3]).to eql(application1.created_at)
      end

      it 'Completed at' do
        expect(line[4]).to eql(application1.completed_at)
      end

      it 'Date Processed' do
        expect(line[5]).to eql(application1.updated_at)
      end

      it 'Decision time in minutes' do
        expect(line[6]).to be(10.0)
      end

      it 'Processing time' do
        expect(line[7]).to be(90.0)
      end

      it 'Paper or digital application' do
        expect(line[8]).to eql('digital')
      end

      it 'Processing office' do
        expect(line[9]).to eql(application1.office.name)
      end

      it 'Outcome' do
        expect(line[10]).to eql('full payment')
      end

      it 'Applicaion status' do
        expect(line[11]).to eql('processed')
      end

      it 'Application type' do
        expect(line[12]).to eql('income')
      end

      it 'Evidence check required' do
        expect(line[13]).to eql('No')
      end
    end

    context 'paper application' do
      let(:line) { data[1] }

      it 'Application reference number' do
        expect(line[0]).to eql(application2.reference)
      end

      it 'Submission date (digital only)' do
        expect(line[1]).to be(nil)
      end

      it 'Date received (paper only)' do
        expect(line[2]).to eql(application2.detail.date_received)
      end

      it 'Created at' do
        expect(line[3]).to eql(application2.created_at)
      end

      it 'Completed at' do
        expect(line[4]).to eql(application2.completed_at)
      end

      it 'Date Processed' do
        expect(line[5]).to eql(application2.updated_at)
      end

      it 'Decision time in minutes' do
        expect(line[6]).to be(2.0)
      end

      it 'Processing time' do
        expect(line[7]).to be(29.0)
      end

      it 'Paper or digital application' do
        expect(line[8]).to eql('paper')
      end

      it 'Processing office' do
        expect(line[9]).to eql(application2.office.name)
      end

      it 'Outcome' do
        expect(line[10]).to eql('full payment')
      end

      it 'Applicaion status' do
        expect(line[11]).to eql('processed')
      end

      it 'Application type' do
        expect(line[12]).to eql('income')
      end

      it 'Evidence check required' do
        expect(line[13]).to eql('No')
      end
    end

  end
end
