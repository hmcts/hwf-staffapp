require 'rails_helper'

RSpec.describe BenefitCheckers::MatchedCitizen do
  subject(:matched) { described_class.new(request, variant, ni_number) }

  let(:request) { { first_name: 'Anna Maria', last_name: 'JONES', date_of_birth: '1980-01-01', nino_fragment: '3456' } }
  let(:variant) { request }
  let(:ni_number) { 'AB123456C' }
  let(:attributes) { { 'dateOfBirth' => { 'date' => '1980-01-01' }, 'name' => { 'firstName' => 'Anna', 'lastName' => 'Jones' } } }
  let(:citizen) { { 'data' => { 'id' => 'guid', 'type' => 'Citizen', 'attributes' => attributes } } }

  describe '#verify' do
    it 'passes when the date of birth and last name agree' do
      expect(matched.verify(citizen)).to be true
      expect(matched.failed_on).to be_nil
    end

    it 'fails on the date of birth first' do
      attributes['dateOfBirth'] = { 'date' => '1981-01-01' }
      attributes['name'] = { 'lastName' => 'Smith' }

      expect(matched.verify(citizen)).to be false
      expect(matched.failed_on).to eq :date_of_birth
    end

    it 'fails on the last name' do
      attributes['name'] = { 'lastName' => 'Smith' }

      expect(matched.verify(citizen)).to be false
      expect(matched.failed_on).to eq :last_name
    end

    it 'ignores case and spaces in the last name' do
      attributes['name'] = { 'lastName' => ' jones ' }

      expect(matched.verify(citizen)).to be true
    end

    it 'accepts the last name held as the alternate name' do
      attributes['name'] = { 'lastName' => 'Smith' }
      attributes['alternateName'] = { 'lastName' => 'JONES' }

      expect(matched.verify(citizen)).to be true
    end

    context 'when a name variant made the match' do
      let(:variant) { request.merge(first_name: 'Anna', last_name: 'Maria JONES') }

      it 'accepts the surname held the way the variant sent it' do
        attributes['name'] = { 'lastName' => 'Maria Jones' }

        expect(matched.verify(citizen)).to be true
      end

      it 'still accepts the surname as built' do
        expect(matched.verify(citizen)).to be true
      end
    end

    context 'when DWP returns the NI number' do
      it 'passes when it is the same, ignoring case and spaces' do
        attributes['nino'] = 'ab 12 34 56 c'

        expect(matched.verify(citizen)).to be true
      end

      it 'fails when it is different' do
        attributes['nino'] = 'ZZ999999Z'

        expect(matched.verify(citizen)).to be false
        expect(matched.failed_on).to eq :ni_number
      end

      context 'and the application has none' do
        let(:ni_number) { nil }

        it 'is not compared' do
          attributes['nino'] = 'ZZ999999Z'

          expect(matched.verify(citizen)).to be true
        end
      end
    end

    it 'does not compare the NI number when DWP leaves it out' do
      expect(matched.verify(citizen)).to be true
      expect(matched.outcome['ni_number_checked']).to be false
    end

    it 'fails on the date of birth when the record has no attributes' do
      expect(matched.verify({ 'data' => {} })).to be false
      expect(matched.failed_on).to eq :date_of_birth
    end
  end

  describe '#compared' do
    let(:variant) { request.merge(first_name: 'Anna', last_name: 'Maria JONES') }

    it 'is our side of the comparison only' do
      expect(matched.compared).to eq(date_of_birth: '1980-01-01', last_names: ['JONES', 'Maria JONES'], ni_number: 'AB123456C')
    end

    it 'leaves out an NI number the application does not have' do
      expect(described_class.new(request, variant, nil).compared.keys).to eq [:date_of_birth, :last_names]
    end
  end

  describe '#outcome' do
    it 'says what failed' do
      attributes['nino'] = 'ZZ999999Z'
      matched.verify(citizen)

      expect(matched.outcome).to eq('verified' => false, 'failed_on' => 'ni_number', 'ni_number_checked' => true)
    end

    it 'says the NI number was not checked when DWP left it out' do
      matched.verify(citizen)

      expect(matched.outcome).to eq('verified' => true, 'failed_on' => nil, 'ni_number_checked' => false)
    end
  end
end
