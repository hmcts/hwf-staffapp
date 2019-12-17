require 'rails_helper'

RSpec.describe Forms::Evidence::Accuracy do
  subject(:form) { described_class.new(evidence) }

  let(:evidence) { build_stubbed :evidence_check }

  it 'inherits features of Forms::Accuracy' do
    expect(form).to be_a(Forms::Accuracy)
  end

  describe '#save' do
    subject(:form_save) { form.save }

    let(:evidence) { create :evidence_check }

    before do
      form.update_attributes(params)
    end

    context 'for a valid form when the evidence is correct' do
      let(:incorrect_reason) { 'REASON' }
      let(:incorrect_reason_category) { ['reason 1', 'reason 2'] }
      let(:params) {
        { correct: true, incorrect_reason: incorrect_reason,
          incorrect_reason_category: incorrect_reason_category }
      }

      before { form_save && evidence.reload }

      it 'keeps the outcome empty' do
        expect(evidence.outcome).to be nil
      end

      it 'keeps the incorrect reason category empty' do
        expect(evidence.incorrect_reason_category).to eql []
      end

      it 'keeps the incorrect reason nil' do
        expect(evidence.incorrect_reason).to be nil
      end

    end

    context 'for a valid form when the evidence is incorrect' do
      let(:staff_error_details) { 'wrong ref number' }
      let(:params) { { correct: false, staff_error_details: staff_error_details } }

      before { form_save && evidence.reload }

      it 'sets the outcome to none' do
        expect(evidence.outcome).to eql('none')
      end

      it 'updates staff_error_details' do
        expect(evidence.staff_error_details).to eql(staff_error_details)
      end
    end
  end
end
