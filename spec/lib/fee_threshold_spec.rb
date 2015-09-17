require 'rails_helper'

RSpec.describe FeeThreshold do
  context '#band' do
    context 'when nil is supplied' do
      it 'returns nil' do
        expect(described_class.new(nil).band).to eq nil
      end
    end

    it 'returns a amount' do
      expect(described_class.new(0).band).to eq 3000
    end

    context 'when fee < 1000' do
      it 'returns 3000' do
        expect(described_class.new(999).band).to eq 3000
      end

      context 'when the fee includes pence' do
        it 'returns 3000' do
          expect(described_class.new(999.50).band).to eq 3000
        end
      end
    end

    context 'the pence push the fee up a band' do
      it 'returns 4000' do
        expect(described_class.new(1000.50).band).to eq 4000
      end
    end

    described_class::FEE_BANDS.each do |band|
      context "when amount is between #{band[:lower]} and #{band[:upper]}" do
        let(:fee) { band[:lower] + 5 }

        it "returns #{band[:amount]}" do
          expect(described_class.new(fee).band).to eq band[:amount]
        end
      end

      context 'when the fee is a float' do
        context 'and it adds 50 pence to the upper band' do
          let(:fee) { band[:upper].to_f + 0.50 }

          it "returns amount that is higher than #{band[:amount]}" do
            expect(described_class.new(fee).band).to be > band[:amount].to_i
          end
        end
      end
    end

    context 'when fee > 7000' do
      context 'when the fee is just over 7000' do
        it 'returns 16000' do
          expect(described_class.new(7001).band).to eq 16000
        end
      end

      context 'when the fee is in pence' do
        it 'returns 16000' do
          expect(described_class.new(7000.50).band).to eq 16000
        end
      end
    end
  end
end
