require 'rails_helper'

RSpec.describe PurgeOnlineApplications do
  subject(:service) { described_class.new }

  describe '#oldest_retention_date' do
    it 'returns 4 months prior to the current date' do
      Timecop.freeze(Date.new(2016, 10, 01)) do
        expect(service.oldest_retention_date).to eql Date.new(2016, 6, 1)
      end
    end
  end

  describe '#affected_records' do

    subject { service.affected_records }

    before do
      Timecop.freeze(Time.zone.now - 5.months) do
        create :online_application, :completed, :with_reference, convert_to_application: true
        create :online_application, :completed, :with_reference
      end
    end

    it 'returns online_applications older than 4 months that were not converted to applications' do
      expect(subject.count).to eq 1
    end
  end

  describe '#now!' do
    before do
      Timecop.freeze(Time.zone.now - 5.months) do
        create :online_application, :completed, reference: 'HWF-XYX-ZWZ', convert_to_application: true
        create :online_application, :completed, reference: 'HWF-ABA-CDC'
      end
      service.now!
    end

    it 'Leaves no affected records' do
      expect(service.affected_records.count).to eq 0
    end

    it 'removes the correct record' do
      expect(OnlineApplication.find_by(reference: 'HWF-ABA-CDC')).to be nil
    end

    it 'leaves the correct record' do
      expect(OnlineApplication.find_by(reference: 'HWF-XYX-ZWZ')).to be_a OnlineApplication
    end
  end
end
