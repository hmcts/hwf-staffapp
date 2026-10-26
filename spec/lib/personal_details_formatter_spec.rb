require 'rails_helper'

RSpec.describe PersonalDetailsFormatter do
  describe '.compact_upcase' do
    it 'removes spaces and upcases' do
      expect(described_class.compact_upcase('jn 01 02 03 a')).to eq 'JN010203A'
    end

    it 'leaves an already formatted value unchanged' do
      expect(described_class.compact_upcase('L1234567/1')).to eq 'L1234567/1'
    end

    it 'returns nil for nil' do
      expect(described_class.compact_upcase(nil)).to be_nil
    end

    it 'returns an empty string for an empty string' do
      expect(described_class.compact_upcase('')).to eq ''
    end
  end

  describe '.postcode' do
    it 'strips surrounding whitespace and upcases' do
      expect(described_class.postcode(' tw14 1uh ')).to eq 'TW14 1UH'
    end

    it 'collapses repeated spaces to one' do
      expect(described_class.postcode('GL7   1HT')).to eq 'GL7 1HT'
    end

    it 'keeps a postcode without a space as entered' do
      expect(described_class.postcode('tw141uh')).to eq 'TW141UH'
    end

    it 'returns nil for nil' do
      expect(described_class.postcode(nil)).to be_nil
    end

    it 'returns nil for blank input' do
      expect(described_class.postcode('   ')).to be_nil
    end
  end
end
