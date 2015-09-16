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

    [
      { lower: 1001, upper: 1335, amount: 4000 },
      { lower: 1336, upper: 1665, amount: 5000 },
      { lower: 1666, upper: 2000, amount: 6000 },
      { lower: 2001, upper: 2330, amount: 7000 },
      { lower: 2331, upper: 4000, amount: 8000 },
      { lower: 4001, upper: 5000, amount: 10000 },
      { lower: 5001, upper: 6000, amount: 12000 },
      { lower: 6001, upper: 7000, amount: 14000 }
    ].each do |band|
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
