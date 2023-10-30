require 'rails_helper'

RSpec.describe Views::Overview::FeeStatus do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }
  let(:online_application) { build_stubbed(:online_application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it do
      is_expected.to eql(['date_received', 'refund_request', 'date_fee_paid', 'discretion_applied',
                          'discretion_manager_name', 'discretion_reason'])
    end
  end

  describe '#date_received' do
    let(:detail) { build_stubbed(:detail, date_received: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_received).to eql('20 November 2015')
    end
  end

  describe '#skip_change_link' do
    let(:application) { build_stubbed(:application) }

    it { expect(view.skip_change_link).to be_nil }

    context 'online_application' do
      let(:application) { online_application }
      it { expect(view.skip_change_link).to eql(['refund_request', 'date_fee_paid']) }
    end
  end

  describe '#date_fee_paid' do
    let(:detail) { build_stubbed(:detail, date_fee_paid: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_fee_paid).to eql('20 November 2015')
    end
  end

  describe 'discretion_applied' do
    context 'online_application' do
      subject(:view) { described_class.new(online_application) }
      it "return nil" do
        expect(view.discretion_applied).to be_nil
      end
    end

    context 'application' do
      let(:application) { build_stubbed(:application, detail: detail) }
      let(:detail) { build_stubbed(:detail, discretion_applied: true) }

      it "return nil" do
        expect(view.discretion_applied).to eql('Yes')
      end
    end
  end
end
