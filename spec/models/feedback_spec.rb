require 'rails_helper'

RSpec.describe Feedback, type: :model do

  let(:feedback) { create :feedback }

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

    it 'requires a rating' do
      feedback.rating = nil
      expect(feedback).to be_invalid
    end
  end

  context 'when the user of the feedback' do
    let(:user)  { create :user }
    let(:office) { create :office }

    before do
      feedback.user = user
      feedback.office = office
      feedback.save
    end

    describe 'is present' do
      it 'still shows the user' do
        expect(feedback.user).to eq user
      end
    end

    describe 'is deleted' do
      before { user.destroy }

      it 'still shows the user' do
        expect(feedback.user).to eq user
      end
    end
  end
end
