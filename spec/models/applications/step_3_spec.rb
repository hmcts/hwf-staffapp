require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application)      { build :application }

  it 'has a valid factory build' do
    expect(application).to be_valid
  end

  describe 'Step 3 - Savings and investments' do
    before { application.status = 'savings_investments' }

    describe 'validations' do
      describe 'savings_threshold' do
        describe 'presence' do
          before do
            application.savings_threshold = nil
            application.valid?
          end

          it 'must be entered' do
            expect(application).to be_invalid
          end

          it 'returns an error if missing' do
            expect(application.errors[:savings_threshold]).to eq ['You must answer the savings question']
          end
        end
      end
    end
  end
end
