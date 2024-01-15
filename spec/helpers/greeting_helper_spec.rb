require 'rails_helper'

RSpec.describe GreetingHelper do
  let(:application) { build(:application, applicant: applicant) }
  let(:confirm) { Views::Confirmation::Result.new(application) }
  let(:rep) { Views::Overview::Representative.new(application.representative) }
  let(:applicant) { build(:applicant, first_name: 'name applicant') }
  let(:representative) { nil }

  before do
    representative
  end

  describe '#greeting_condition' do
    context 'when representative is not nil' do
      let(:representative) { build(:representative, application: application, first_name: 'name', last_name: 'representative') }

      it 'returns the correct greeting when representative_full_name is present' do
        result = helper.greeting_condition(confirm, application)
        expect(result).to eq('name representative regarding name applicant')
      end
    end

    context 'when representative is nil' do
      let(:representative) { nil }

      it 'returns the correct greeting when representative_full_name is not present' do
        result = helper.greeting_condition(confirm, application)
        expect(result).to eq('name applicant')
      end
    end
  end

  describe '#greeting_condition2' do
    context 'when representative is not nil' do
      let(:representative) { build(:representative, application: application, first_name: 'name', last_name: 'representative') }

      it 'returns the correct greeting when representative.full_name is present' do
        result = helper.greeting_condition2(rep, applicant)
        expect(result).to eq('name representative regarding name applicant')
      end
    end

    context 'when representative is nil' do
      let(:representative) { nil }

      it 'returns the correct greeting when representative.full_name is not present' do
        result = helper.greeting_condition2(rep, applicant)
        expect(result).to eq('name applicant')
      end
    end
  end
end
