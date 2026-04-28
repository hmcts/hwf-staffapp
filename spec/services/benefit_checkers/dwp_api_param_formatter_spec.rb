require 'rails_helper'

RSpec.describe BenefitCheckers::DwpApiParamFormatter do
  let(:test_class) do
    Class.new do
      include BenefitCheckers::DwpApiParamFormatter

      public :citizen_params, :format_date, :extract_nino_fragment
    end
  end
  let(:formatter) { test_class.new }

  describe '#citizen_params' do
    let(:params) do
      {
        surname: 'SMITH',
        birth_date: '19900315',
        ni_number: 'AB123456C'
      }
    end

    it 'maps surname to last_name' do
      expect(formatter.citizen_params(params)[:last_name]).to eq('SMITH')
    end

    it 'formats the date of birth' do
      expect(formatter.citizen_params(params)[:date_of_birth]).to eq('1990-03-15')
    end

    it 'extracts the nino fragment' do
      expect(formatter.citizen_params(params)[:nino_fragment]).to eq('3456')
    end

    it 'omits nil values with compact' do
      result = formatter.citizen_params(params.merge(ni_number: nil, birth_date: nil))
      expect(result.keys).to eq([:last_name])
    end
  end

  describe '#format_date' do
    it 'converts YYYYMMDD to YYYY-MM-DD' do
      expect(formatter.format_date('20251231')).to eq('2025-12-31')
    end

    it 'returns nil for blank input' do
      expect(formatter.format_date('')).to be_nil
    end

    it 'returns nil for nil input' do
      expect(formatter.format_date(nil)).to be_nil
    end
  end

  describe '#extract_nino_fragment' do
    it 'returns last 4 digits of a standard NINO' do
      expect(formatter.extract_nino_fragment('AB123456C')).to eq('3456')
    end

    it 'handles NINOs without suffix letter' do
      expect(formatter.extract_nino_fragment('AB12345678')).to eq('5678')
    end

    it 'returns nil for blank input' do
      expect(formatter.extract_nino_fragment('')).to be_nil
    end

    it 'returns nil for nil input' do
      expect(formatter.extract_nino_fragment(nil)).to be_nil
    end
  end
end
