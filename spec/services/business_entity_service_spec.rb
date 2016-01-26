# coding: utf-8
require 'rails_helper'

describe BusinessEntityService do
  let!(:office) { create :office }
  let!(:jurisdiction) { office.jurisdictions[0] }
  let(:service) { described_class.new(office, jurisdiction) }

  subject { service }

  describe 'when initialized with the correct variables' do
    it { is_expected.to be_a_kind_of described_class }
  end

  describe '#build_new' do
    let(:params) { { name: name, code: code } }
    subject { service.build_new(params) }

    describe 'when sent correct values' do
      let(:name) { 'test-jurisdiction' }
      let(:code) { 'AB123' }

      it { is_expected.to be_a_kind_of BusinessEntity }

      it 'does not persist the object' do
        expect(subject.persisted?).to be false
      end

      it 'returns a valid object' do
        expect(subject.valid?).to be true
      end
    end

    describe 'when sent incorrect values' do
      let(:name) { 'test-jurisdiction' }
      let(:code) { nil }

      it 'does not persist the object' do
        expect(subject.persisted?).to be false
      end

      it 'returns an invalid object' do
        expect(subject.valid?).to be false
      end
    end
  end

  describe '#build_update' do
    let(:params) { { name: name, code: code } }
    subject { service.build_update(params) }
    let(:business_entity) { BusinessEntity.current_for(office, jurisdiction) }

    describe 'when sent both correct values' do
      let(:name) { 'test-jurisdiction' }
      let(:code) { business_entity.code.reverse }

      it { is_expected.to be_a_kind_of BusinessEntity }

      it 'returns a new, non-persisted object' do
        expect(subject.persisted?).to be false
      end

      it 'returns a valid object' do
        expect(subject.valid?).to be true
      end

      it 'has no ID' do
        expect(subject.id).to be nil
      end
    end

    describe 'when sent an updated name only' do
      let(:name) { 'test-jurisdiction' }
      let(:code) { business_entity.code }

      it { is_expected.to be_a_kind_of BusinessEntity }

      it 'returns the existing persisted object' do
        expect(subject.persisted?).to be true
      end

      it 'returns a valid object' do
        expect(subject.valid?).to be true
      end

      it 'has the ID of the existing business_entity' do
        expect(subject.id).to eq business_entity.id
      end
    end

    describe 'when sent incorrect values' do
      let(:name) { 'test-jurisdiction' }
      let(:code) { nil }

      it 'does not persist the object' do
        expect(subject.persisted?).to be false
      end

      it 'returns an invalid object' do
        expect(subject.valid?).to be false
      end
    end
  end

  describe '#build_deactivate' do
    subject { service.build_deactivate }

    it { is_expected.to be_a_kind_of BusinessEntity }

    it 'returns a persisted object' do
      expect(subject.persisted?).to be true
    end

    it 'returns a valid object' do
      expect(subject.valid?).to be true
    end

    it 'has no valid_to' do
      expect(subject.valid_to).not_to be nil
    end
  end

  describe '#persist!' do
    let!(:business_entity) { BusinessEntity.current_for(office, jurisdiction) }

    subject(:persist) { service.persist! }

    context 'when persisting a new object' do
      before { service.build_new(name: 'Test', code: 'XY123') }

      it 'creates a new business_entity' do
        expect { persist }.to change { BusinessEntity.count }.by 1
      end
    end

    context 'when persisting an update' do
      context 'that changes the code' do
        before { service.build_update(name: 'Test', code: 'XY123') }

        it 'creates a new business_entity' do
          expect { persist }.to change { BusinessEntity.count }.by 1
        end

        it 'sets the valid_to date of the existing business_entity' do
          service.persist!
          business_entity.reload
          expect(business_entity.valid_to).not_to eq nil
        end
      end

      context 'that does not change the code' do
        it 'creates a new business_entity' do
          expect { service.persist! }.to_not change { BusinessEntity.count }
        end
      end
    end

    context 'when persisting a deactivation' do
      before do
        service.build_deactivate
        service.persist!
        business_entity.reload
      end

      it 'sets the valid_to date of the existing business_entity' do
        expect(business_entity.valid_to).not_to eq nil
      end

      it 'sets the current office and jurisdiction business_entity to nil' do
        expect(BusinessEntity.current_for(office, jurisdiction)).to be nil
      end
    end
  end
end
