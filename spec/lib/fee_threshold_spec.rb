require 'rails_helper'

RSpec.describe FeeThreshold do
  let(:application) { create :application }
  subject { described_class.new(application) }

  context '.band' do
    it 'returns a amount' do
      expect(subject.band).to eq 3000
    end

    context 'when fee < 1000' do
      before { application.fee = 999 }
      it 'returns 3000' do
        expect(subject.band).to eq 3000
      end
    end

    described_class::FEE_BANDS.each do |band|
      context "when amount is between #{band[:lower]} and #{band[:upper]}" do
        before { application.fee = band[:lower] + 5 }
        it "returns #{band[:amount]}" do
          expect(subject.band).to eq band[:amount]
        end
      end
    end

    context 'when fee > 7000' do
      before { application.fee = 7001 }
      it 'returns 16000' do
        expect(subject.band).to eq 16000
      end
    end
  end
end
