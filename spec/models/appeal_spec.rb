require 'rails_helper'

RSpec.describe Appeal do
  subject(:appeal) { build_stubbed(:appeal) }

  it { is_expected.to belong_to(:application).required(true) }
  it { is_expected.to belong_to(:completed_by).class_name('User').required(true) }

  describe 'correct' do
    it 'defaults to false' do
      expect(described_class.new.correct).to be false
    end
  end
end
