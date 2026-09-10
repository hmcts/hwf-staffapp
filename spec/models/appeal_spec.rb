require 'rails_helper'

RSpec.describe Appeal do
  subject(:appeal) { build_stubbed(:appeal) }

  it { is_expected.to belong_to(:application).required(true) }
  it { is_expected.to belong_to(:completed_by).class_name('User').required(true) }

  describe 'one appeal per application' do
    let(:application) { create(:application) }

    it 'does not allow a second appeal for the same application' do
      create(:appeal, application: application)
      second = build(:appeal, application: application)

      expect(second).not_to be_valid
      expect(second.errors[:application_id]).to be_present
    end
  end

  describe 'correct' do
    it 'defaults to false' do
      expect(described_class.new.correct).to be false
    end
  end
end
