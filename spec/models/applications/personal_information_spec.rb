require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application)      { build :application }

  it 'has a valid factory build' do
    expect(application).to be_valid
  end

  describe 'Step 1 - Personal details' do
    before { application.status = 'personal_information' }

    describe 'methods' do
      describe 'full_name' do
        it 'provides response' do
          application.title = 'Mr'
          application.first_name = 'John'
          application.last_name = 'Smith'
          expect(application.full_name).to eq 'Mr John Smith'
        end
      end
    end
    describe 'validation for' do
      describe 'last name' do
        describe 'presence' do
          before do
            application.last_name = nil
            application.valid?
          end

          it 'is required' do
            expect(application).to be_invalid
          end

          it 'returns an error message' do
            expect(application.errors[:last_name]).to eq ["Enter the applicant's last name"]
          end
        end

        describe 'length' do
          before do
            application.last_name = 'Q'
            application.valid?
          end

          it 'must be at least 2 characters' do
            expect(application).to be_invalid
          end

          it 'must be at least 2 characters' do
            expect(application.errors[:last_name]).to eq ['Last name is too short (minimum is 2 characters)']
          end
        end
      end

      describe 'date of birth' do
        it 'is required' do
          application.date_of_birth = nil
          expect(application).to be_invalid
        end

        describe 'maximum age' do
          before do
            application.date_of_birth = Time.zone.today - 121.years
            application.valid?
          end

          it 'must be under 120 years' do
            expect(application).to be_invalid
          end

          it 'returns an error message' do
            error = ["The applicant can't be over #{Application::MAX_AGE} years old"]
            expect(application.errors.messages[:date_of_birth]).to eq error
          end
        end

        describe 'minimum age' do
          before do
            application.date_of_birth = Time.zone.today
            application.valid?
          end

          it 'must be over 16' do
            expect(application).to be_invalid
          end

          it 'returns an error message' do
            error = ["The applicant can't be under #{Application::MIN_AGE} years old"]
            expect(application.errors[:date_of_birth]).to eq error
          end
        end
      end

      describe 'marital status' do
        it 'accepts true as a value' do
          application.married = true
          expect(application).to be_valid
        end

        it 'accepts false as a value' do
          application.married = false
          expect(application).to be_valid
        end

        it 'is required' do
          application.married = nil
          expect(application).to be_invalid
        end

        it 'returns an error message if not set' do
          application.married = nil
          application.valid?
          error = ['Please select a marital status']
          expect(application.errors[:married]).to eq error
        end
      end

      describe 'national insurance number' do
        it 'is not required' do
          application.ni_number = nil
          expect(application).to be_valid
        end

        it 'is displayed in the required format' do
          application.ni_number = 'CD123456D'
          expect(application.ni_number_display).to eq 'CD 12 34 56 D'
        end

        it 'can be duplicated' do
          create(:application, ni_number: 'AB123456A', date_received: nil)
          duplicate = build(:application, ni_number: 'AB123456A')
          expect(duplicate).to be_valid
        end

        describe 'invalid format' do
          before do
            application.ni_number = 'bob'
            application.valid?
          end

          it 'is rejected' do
            expect(application).to be_invalid
          end

          it 'return an error message' do
            error = ['Enter 2 letters, 6 numbers and 1 letter for the National Insurance number']
            expect(application.errors[:ni_number]).to eq error
          end
        end
      end
    end
  end
end
