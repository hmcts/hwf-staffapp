require 'rails_helper'

RSpec.describe SavingsTransformation do

  subject(:transform) { described_class.new }

  let!(:application1) { create :application_full_remission }
  let!(:application2) { create :application_full_remission, threshold_exceeded: true, high_threshold_exceeded: true }
  let!(:application3) { create :married_applicant_over_61, threshold_exceeded: true }
  let!(:application4) { create :application_full_remission, :partner_over_61 }
  let!(:application5) do
    create(:application_full_remission, fee: nil).tap do |a|
      create(:detail, fee: nil, application: a)
    end
  end
  before { Saving.delete_all }

  describe '#up!' do
    before do
      transform.up!
      application1.reload
      application2.reload
      application3.reload
      application4.reload
      application5.reload
    end

    it 'creates a saving for each application' do
      expect(Application.all.count).to eql Saving.all.count
    end

    it 'creates the saving model' do
      expect(application1.saving.present?).to eql(true)
    end

    it 'sets `passed` to false when maximum threshold exceeded' do
      expect(application2.saving.passed).to eql(false)
    end

    it 'sets `over_61` to true when the applicant is over_61' do
      expect(application3.saving.over_61).to eql(true)
    end

    it 'sets `over_61` to match partner_over_61' do
      expect(application4.saving.over_61).to eql(true)
    end

    it 'sets the fee_threshold to minimum when the fee is nil' do
      expect(application5.saving.fee_threshold).to eql(3000)
    end

    it 'sets passed to equal savings_and_investments_valid? on the application' do
      expect(application1.saving.passed).to be true
      expect(application2.saving.passed).to be false
      expect(application3.saving.passed).to be false
      expect(application4.saving.passed).to be true
      expect(application5.saving.passed).to be true
    end
  end
end
