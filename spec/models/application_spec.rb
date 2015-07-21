require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application)      { build :application }

  it 'has a valid factory build' do
    expect(application).to be_valid
  end

  describe 'Step 2 - Application details' do
    before { application.status = 'application_details' }

    describe 'validation for' do
      describe 'fee' do
        describe 'presence' do
          before do
            application.fee = nil
            application.valid?
          end

          it 'is required' do
            expect(application).to be_invalid
          end

          it 'returns an error message, if omitted' do
            expect(application.errors[:fee]).to eq ['Enter the fee']
          end
        end
        describe 'numericality' do
          before do
            application.fee = 'Ten pounds'
            application.valid?
          end

          it 'returns invalid if non-numeric'do
            expect(application).to be_invalid
          end

          it 'returns an error message' do
            expect(application.errors[:fee]).to eq ['The fee should be numeric']
          end
        end
      end

      describe 'jurisdiction' do
        describe 'presence' do
          before do
            application.jurisdiction_id = nil
            application.valid?
          end

          it 'is required' do
            expect(application).to be_invalid
          end

          it 'returns an error message, if omitted' do
            expect(application.errors[:jurisdiction_id]).to eq ['You must select a jurisdiction']
          end
        end
      end

      describe 'Date application received' do
        describe 'presence' do
          before do
            application.date_received = nil
            application.valid?
          end

          it 'is required' do
            expect(application).to be_invalid
          end

          it 'returns an error message, if omitted' do
            expect(application.errors[:date_received]).to eq ['Enter the date in this format 01/01/2015']
          end
        end

        describe 'range' do
          it 'allows between today and 3 months ago' do
            application.date_received = Time.zone.today
            expect(application).to be_valid
          end

          describe 'maximum' do
            before do
              application.date_received = Time.zone.today.-3.months.+1.day
              application.valid?
            end

            it 'is 3 months' do
              expect(application).to be_invalid
            end

            it 'returns an error if exceeded' do
              expect(application.errors[:date_received]).to eq ['The application must have been made in the last 3 months']
            end
          end

          describe 'minimum' do
            before do
              application.date_received = Time.zone.tomorrow
              application.valid?
            end

            it 'is today' do
              expect(application).to be_invalid
            end

            it 'returns an error if too low' do
              expect(application.errors[:date_received]).to eq ['The application cannot be a future date']
            end
          end
        end
      end

      describe 'probate' do
        let(:probate)      { build :probate_application }

        it 'has a valid factory build' do
          expect(probate).to be_valid
        end

        it 'passes if probate unchecked' do
          probate.probate = false
          probate.date_of_birth = nil
          probate.deceased_name = nil
          expect(probate).to be_valid
        end

        describe 'requires' do
          describe 'date of death' do
            describe 'presence' do
              before do
                probate.date_of_death = nil
                probate.valid?
              end

              it 'must be entered' do
                expect(probate).to be_invalid
              end

              it 'returns an error if missing' do
                expect(probate.errors[:date_of_death]).to eq ['Enter the date in this format 01/01/2015']
              end
            end

            describe 'range' do
              it 'must be prior to today' do
                probate.date_of_death = Time.zone.tomorrow
                expect(probate).to be_invalid
              end
            end
          end
          describe 'deceased name' do
            before do
              probate.deceased_name = nil
              probate.valid?
            end

            it 'must be entered' do
              expect(probate).to be_invalid
            end
            it 'returns an error if missing' do
              expect(probate.errors[:deceased_name]).to eq ["The deceased's name should be entered"]
            end
          end
        end
      end

      describe 'refund' do
        let(:refund) { build :refund_application }

        it 'has a valid factory build' do
          expect(refund).to be_valid
        end

        it 'passes if refund unchecked' do
          refund.refund = false
          refund.date_fee_paid = nil
          expect(refund).to be_valid
        end
        describe 'date fee paid' do
          describe 'range' do
            it 'allows between today and 3 months ago' do
              refund.date_fee_paid = Time.zone.today
              expect(refund).to be_valid
            end

            describe 'maximum' do
              before do
                refund.date_fee_paid = Time.zone.today.-3.months.+1.day
                refund.valid?
              end

              it 'is 3 months' do
                expect(refund).to be_invalid
              end

              it 'returns an error if exceeded' do
                expect(refund.errors[:date_fee_paid]).to eq ['The application must have been made in the last 3 months']
              end
            end

            describe 'minimum' do
              before do
                refund.date_fee_paid = Time.zone.tomorrow
                refund.valid?
              end

              it 'is today' do
                expect(refund).to be_invalid
              end

              it 'returns an error if too low' do
                expect(refund.errors[:date_fee_paid]).to eq ['The application cannot be a future date']
              end
            end
          end

          describe 'presence' do
            before do
              refund.date_fee_paid = nil
              refund.valid?
            end

            it 'is required' do
              expect(refund).to be_invalid
            end
            it 'returns an error if missing' do
              expect(refund.errors[:date_fee_paid]).to eq ['Enter the date in this format 01/01/2015']
            end
          end
        end
      end
    end
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
            expect(application.errors[:last_name]).to eq ['is too short (minimum is 2 characters)']
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
          create(:application, ni_number: 'AB123456A')
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
