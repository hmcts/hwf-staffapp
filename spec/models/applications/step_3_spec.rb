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
            application.threshold_exceeded = nil
            application.valid?
          end

          it 'must be entered' do
            expect(application).to be_invalid
          end

          it 'returns an error if missing' do
            expect(application.errors[:threshold_exceeded]).to eq ['You must answer the savings question']
          end
        end
      end

      context 'threshold_exceeded is true' do
        before { application.threshold_exceeded = true }

        describe 'over_61' do
          before do
            application.over_61 = nil
            application.valid?
          end

          it 'must be present' do
            expect(application).to be_invalid
          end
        end
      end

      context 'savings_threshold is false' do
        describe 'over_61' do
          it 'must be nil'

        end
      end
    end
  end
end
