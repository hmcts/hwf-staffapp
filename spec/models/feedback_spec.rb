require 'rails_helper'

RSpec.describe Feedback, type: :model do

  let(:feedback) { build :feedback }

  it 'passes factory build' do
    expect(feedback).to be_valid
  end
  context 'validations' do
    it 'requires a user to stored' do
      feedback.user = nil
      expect(feedback).to be_invalid
    end
    it 'requires an office to be stored' do
      feedback.office = nil
      expect(feedback).to be_invalid
    end
  end
end
