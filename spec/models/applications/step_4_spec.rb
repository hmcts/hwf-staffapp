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
      end
    end
  end
end
