require 'rails_helper'

RSpec.describe FlashMessageHelper, type: :helper do

  it { expect(helper).to be_a described_class }

  describe '#format_managers_combined_contacts' do
    context ' when not expected to start a sentence' do
      subject { helper.format_managers_combined_contacts(managers) }

      context 'when passed a collection of Users' do
        let(:managers) { create_list :manager, 2 }
        it 'returns a single html mailto link with all managers' do
          is_expected.to eql("<a href='mailto:user_1@digital.justice.gov.uk;user_2@digital.justice.gov.uk'>managers</a>")
        end
      end

      context 'when passed no users' do
        let(:managers) { [] }
        it 'returns a  string' do
          is_expected.to eql('a manager')
        end
      end
    end

    context 'when expected to start a sentence' do
      subject { helper.format_managers_combined_contacts(managers, true) }

      context 'when passed a collection of Users' do
        let(:managers) { create_list :manager, 2 }
        it 'returns a single html mailto link with all managers with capitalised text' do
          is_expected.to eql("<a href='mailto:user_1@digital.justice.gov.uk;user_2@digital.justice.gov.uk'>Managers</a>")
        end
      end

      context 'when passed no users' do
        let(:managers) { [] }
        it 'returns a capitalised string' do
          is_expected.to eql('A manager')
        end
      end
    end
  end
end
