require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application) { build :application }

  it 'has a valid factory build' do
    expect(application).to be_valid
  end

  describe 'Step 4 - Benefits' do
    before { application.status = 'benefits' }

    describe 'validations' do
      describe 'benefits' do
        describe 'presence' do
          before do
            application.benefits = nil
            application.valid?
          end

          it 'must be entered' do
            expect(application).to be_invalid
          end

          it 'returns an error if missing' do
            expect(application.errors[:benefits]).to eq ['You must answer the benefits question']
          end
        end

        describe 'validation' do
          context 'when user selects yes for benefits' do
            before do
              application.income = nil
              application.benefits = true
              application.save
            end

            it 'sets application_type to benefits' do
              expect(application.application_type).to eq 'benefit'
            end
          end

          context 'when user selects no for benefits' do
            before do
              application.benefits = false
              application.save
            end

            it 'sets application_type to income' do
              expect(application.application_type).to eq 'income'
            end
          end
        end
      end
    end
  end
end
