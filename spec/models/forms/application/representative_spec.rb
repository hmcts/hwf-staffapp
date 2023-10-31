require 'rails_helper'

RSpec.describe Forms::Application::Representative do
  subject { described_class.new(representative) }

  let(:representative) { build(:representative, application: application) }
  let(:application) { build(:application) }

  params_list = [:first_name, :last_name, :organisation]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe '#save' do
    subject(:form) { described_class.new(representative) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    context 'when attributes are correct' do
      let(:params) { { first_name: 'john', last_name: 'doe', organisation: 'ltd' } }

      it { is_expected.to be true }

      before do
        update_form
        representative.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(representative.send(key)).to eql(value)
        end
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { first_name: nil } }

      it { is_expected.to be false }
    end
  end
end
