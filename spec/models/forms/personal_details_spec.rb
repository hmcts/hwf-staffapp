require 'rails_helper'

RSpec.describe Forms::PersonalDetails do

  subject { described_class.new }

  describe '#permitted_attributes' do
    let(:params_list) { %i[title first_name last_name date_of_birth ni_number married] }

    it 'returns a list of attributes' do
      expect(subject.permitted_attributes).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_least(2) }

    it { is_expected.to validate_presence_of(:date_of_birth) }

  end

end
