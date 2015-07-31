require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application) { build :application }

  it 'has a valid factory build' do
    expect(application).to be_valid
  end

  describe 'Step 5 - Income' do
    before { application.status = 'income' }

    describe 'validations' do
      describe 'income' do
        describe 'presence' do
          before do
            application.children = nil
            application.valid?
          end

          it 'must be entered' do
            expect(application).to be_invalid
          end

          it 'returns an error if missing' do
            expect(application.errors[:children]).to eq ['is not a number']
          end
        end
      end
    end
  end
end
