require 'rails_helper'

RSpec.describe BenefitCheckers::NameVariants do
  subject(:variants) { described_class.for(request) }

  let(:request) { { first_name: first_name, last_name: last_name, date_of_birth: '1980-01-01', nino_fragment: '3456' } }
  let(:first_name) { 'Anna' }
  let(:last_name) { 'JONES' }

  context 'when both names are one word' do
    it 'is just the request as built' do
      expect(variants.map(&:request)).to eq([request])
      expect(variants.map(&:label)).to eq(['as sent'])
    end
  end

  context 'when the first name has a middle name' do
    let(:first_name) { 'Anna Maria' }

    it 'tries as built, then without the middle name, then with it joined to the last name' do
      expect(variants.map { |v| v.request.values_at(:first_name, :last_name) }).to eq(
        [['Anna Maria', 'JONES'], ['Anna', 'JONES'], ['Anna', 'Maria JONES']]
      )
    end

    it 'keeps everything else in the request as it was' do
      expect(variants.map(&:request)).to all(include(date_of_birth: '1980-01-01', nino_fragment: '3456'))
    end

    it 'labels each way the name was sent' do
      expect(variants.map(&:label)).to eq(['as sent', 'middle name dropped', 'middle name joined to last name'])
    end
  end

  context 'when the last name has more than one word' do
    let(:last_name) { 'VAN JONES' }

    it 'tries as built, then the last word only, then the leading part moved to the first name' do
      expect(variants.map { |v| v.request.values_at(:first_name, :last_name) }).to eq(
        [['Anna', 'VAN JONES'], ['Anna', 'JONES'], ['Anna VAN', 'JONES']]
      )
    end
  end

  context 'when both names have more than one word' do
    let(:first_name) { 'Anna Maria' }
    let(:last_name) { 'VAN JONES' }

    it 'tries the first name variants and then the last name variants, five in all' do
      expect(variants.map { |v| v.request.values_at(:first_name, :last_name) }).to eq(
        [['Anna Maria', 'VAN JONES'], ['Anna', 'VAN JONES'], ['Anna', 'Maria VAN JONES'],
         ['Anna Maria', 'JONES'], ['Anna Maria VAN', 'JONES']]
      )
      expect(variants.map(&:label).last(2)).to eq(['leading part of last name dropped',
                                                   'leading part of last name joined to first name'])
    end
  end

  context 'when the request has no first name' do
    let(:request) { { last_name: 'VAN JONES', date_of_birth: '1980-01-01' } }

    it 'still splits the last name' do
      expect(variants.map { |v| v.request.values_at(:first_name, :last_name) }).to eq(
        [[nil, 'VAN JONES'], [nil, 'JONES'], ['VAN', 'JONES']]
      )
    end
  end

  context 'when a name has extra spaces' do
    let(:first_name) { ' Anna  Maria ' }

    it 'treats the words the same as single spaced names' do
      expect(variants.drop(1).map { |v| v.request.values_at(:first_name, :last_name) }).to eq(
        [['Anna', 'JONES'], ['Anna', 'Maria JONES']]
      )
    end
  end
end
