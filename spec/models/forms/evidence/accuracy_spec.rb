require 'rails_helper'

RSpec.describe Forms::Evidence::Accuracy do
  let(:evidence) { build_stubbed :evidence_check }
  subject(:form) { described_class.new(evidence) }

  it 'inherits features of Forms::Accuracy' do
    expect(form).to be_a(Forms::Accuracy)
  end

  describe '#save' do
    let(:evidence) { create :evidence_check }

    before do
      form.update_attributes(params)
    end

    subject { form.save }

    context 'for a valid form when the evidence is correct' do
      let(:params) { { correct: true } }

      before { subject && evidence.reload }

      it 'keeps the outcome empty' do
        expect(evidence.outcome).to be nil
      end
    end

    context 'for a valid form when the evidence is incorrect' do
      let(:incorrect_reason) { 'REASON' }
      let(:params) { { correct: false, incorrect_reason: incorrect_reason } }

      before { subject && evidence.reload }

      it 'sets the outcome to none' do
        expect(evidence.outcome).to eql('none')
      end
    end
  end
end
