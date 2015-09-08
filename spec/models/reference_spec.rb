require 'rails_helper'

RSpec.describe Reference, type: :model do

  let(:code) { 'foo' }
  let(:reference) { described_class.new }
  let(:current_year) { Time.zone.now.strftime('%y') }
  let(:next_year) { current_year.to_i + 1 }

  describe 'validations' do
    it 'needs to have a reference' do
      reference.reference = ''
      expect(reference).not_to be_valid
    end
  end

  describe 'reference format' do
    context 'enforce the year' do
      it 'needs to be the current year' do
        reference.reference = 'BE133-11-1'
        expect(reference).not_to be_valid
      end

      it 'passes with the current year' do
        reference.reference = "BE133-#{current_year}-1"
        expect(reference).to be_valid
      end
    end

    context 'enforce the reference format' do
      describe 'has 2 alphabetic characters, 3 numbers, "-", year, "-" & count' do
        it 'passes when valid' do
          reference.reference = "BE133-#{current_year}-1"
          expect(reference).to be_valid
        end

        it 'fails when invalid' do
          reference.reference = "BE13-#{current_year}-1"
          expect(reference).not_to be_valid
        end
      end

      context 'increments for the subsequent entry' do
        before { described_class.create(reference: "BE133-#{current_year}-1") }

        it 'passes for the subsequent entry' do
          reference.reference = "BE133-#{current_year}-2"
          expect(reference).to be_valid
        end
      end
    end

    context 'the following year' do
      before do
        reference.reference = "BE131-#{current_year}-1"
        reference.save
        Timecop.freeze(Time.zone.local(2016))
      end

      after { Timecop.return }

      let(:new_reference) { described_class.new }

      it 'resets counter' do
        new_reference.reference = "BE133-#{next_year}-1"
        expect(new_reference).to be_valid
      end

      context 'when an entry exists in the new year' do
        before { described_class.create(reference: "BE131-#{next_year}-1") }

        it 'adds the subsequent entry in order' do
          new_reference.reference = "BE131-#{next_year}-2"
          expect(new_reference).to be_valid
        end
      end

      describe 'counter validation' do
        let(:reference) { described_class.new }

        it 'errors for invalid counter' do
          new_reference.reference = "BE133-#{next_year}-23"
          expect(new_reference).not_to be_valid
        end
      end
    end
  end
end
