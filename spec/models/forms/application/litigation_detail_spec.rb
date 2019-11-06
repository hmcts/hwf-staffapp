require 'rails_helper'

RSpec.describe Forms::Application::LitigationDetail do

  subject(:created_applicant) { described_class.new(litigation_detail) }

  params_list = [:litigation_friend_details]

  let(:litigation_detail) { attributes_for :applicant }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:litigation_friend_details) }
  end

  describe 'when Applicant object is passed in' do
    let(:applicant) { build(:applicant) }
    let(:form) { described_class.new(applicant) }

    params_list.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq applicant.send(attr_name)
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(applicant) }

    subject(:form_save) do
      form.update_attributes(params)
      form.save
    end

    let(:applicant) { create :applicant }

    context 'when the attributes are correct' do
      let(:params) do
        {
          litigation_friend_details: 'as a friend'
        }
      end

      it { is_expected.to be true }

      before do
        form_save
        applicant.reload
      end

      it 'saves the parameters in the applicant' do
        params.each do |key, value|
          expect(applicant.send(key)).to eql(value)
        end
      end

    end

    context 'when the attributes are incorrect' do
      let(:params) { { litigation_friend_details: '' } }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end
end
