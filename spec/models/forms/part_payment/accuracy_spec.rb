require 'rails_helper'

RSpec.describe Forms::PartPayment::Accuracy do
  let(:part_payment) { build_stubbed :part_payment }
  subject(:form) { described_class.new(part_payment) }

  it 'inherits features of Forms::Accuracy' do
    expect(form).to be_a(Forms::Accuracy)
  end

  describe '#save' do
    let(:part_payment) { create :part_payment }

    before do
      form.update_attributes(params)
    end

    subject(:outcome) do
      form.save
      part_payment.reload.outcome
    end

    context 'for a valid form when the part payment is correct' do
      let(:params) { { correct: true } }

      it 'sets the outcome to part' do
        is_expected.to eql('part')
      end
    end

    context 'for a valid form when the part payment is incorrect' do
      let(:incorrect_reason) { 'REASON' }
      let(:params) { { correct: false, incorrect_reason: incorrect_reason } }

      it 'sets the outcome to none' do
        is_expected.to eql('none')
      end
    end
  end
end
