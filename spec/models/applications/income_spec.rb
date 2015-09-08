require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application) { build :application }

  it 'has a valid factory build' do
    expect(application).to be_valid
  end

  describe 'Step 5 - Income' do
    before do
      application.threshold_exceeded = false
      application.benefits = false
      application.status = 'income'
    end

    describe 'validations' do
      describe 'dependents' do
        context 'when nil' do
          before do
            application.dependents = nil
            application.valid?
          end

          it 'must be entered' do
            expect(application).to be_invalid
          end
        end

        context 'when true' do
          before do
            application.dependents = true
            application.valid?
          end

          context 'children equals zero' do
            before do
              application.children = 0
              application.valid?
            end

            it 'returns an error' do
              expect(application.errors[:children]).to eq ['Choose number of children']
            end

            it 'invalidates the object' do
              expect(application).to be_invalid
            end
          end
        end

        context 'when false' do
          before do
            application.dependents = false
            application.valid?
          end

          context 'children greater than zero' do
            before do
              application.children = 1
              application.valid?
            end

            it 'resets children to 0' do
              expect(application.children).to eq 0
            end
          end
        end

        context 'when either true or false' do
          [true, false].each do |val|
            before { application.dependents = val }

            context 'income is set' do
              before do
                application.income = '300'
                application.valid?
              end

              it 'is valid' do
                expect(application).to be_valid
              end
            end

            context 'income is empty' do
              before do
                application.income = nil
                application.valid?
              end

              it 'invalidates the object' do
                expect(application).to be_invalid
              end

              it 'adds an error message' do
                expect(application.errors[:income]).to eq ['Enter the total monthly income']
              end
            end
          end
        end
      end
    end
  end
end
