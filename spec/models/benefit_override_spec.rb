require 'rails_helper'

RSpec.describe BenefitOverride do
  it { is_expected.to validate_presence_of(:application) }

  describe 'reprocessed' do
    it 'defaults to false' do
      expect(described_class.new.reprocessed).to be false
    end
  end
end
