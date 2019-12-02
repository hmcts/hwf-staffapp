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
      let(:params) { { correct: true } }

      before { form_save && evidence.reload }

      it 'keeps the outcome empty' do
        expect(evidence.outcome).to be nil
      end
    end

    context 'for a valid form when the evidence is incorrect' do
      let(:incorrect_reason) { 'REASON' }
      let(:params) { { correct: false, incorrect_reason: incorrect_reason } }

      before { form_save && evidence.reload }

      it 'sets the outcome to none' do
        expect(evidence.outcome).to eql('none')
      end
    end
  end
end
