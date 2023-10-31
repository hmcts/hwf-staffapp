require 'rails_helper'

RSpec.describe Views::Overview::Representative do
  subject(:view) { described_class.new(representative) }

  let(:application) { build_stubbed(:application) }
  let(:representative) { build_stubbed(:representative, application: application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it do
      is_expected.to eql(["full_name", "organisation"])
    end
  end

  describe '#full_name' do
    subject { view.full_name }

    context 'blank' do
      let(:representative) { build_stubbed(:representative, application: application, first_name: nil, last_name: nil) }
      it { is_expected.to eq '' }
    end

    context 'with information' do
      let(:representative) { build_stubbed(:representative, application: application, first_name: 'John', last_name: 'Doe') }

      it { is_expected.to eq 'John Doe' }
    end
  end

  context 'display_section?' do
    subject { view.display_section? }
    let(:representative) { nil }

    it { is_expected.to be false }
  end

end
