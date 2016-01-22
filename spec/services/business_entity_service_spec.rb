# coding: utf-8
require 'rails_helper'

describe BusinessEntityService do
  let(:office) { create :office }
  let(:jurisdiction) { office.jurisdictions[0] }
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

  describe '#persist!' do
    subject(:persist) { service.persist! }

    context 'when persisting a new object' do
      before { service.build_new(name: 'Test', code: 'XY123') }

      it 'creates a new business_entity' do
        expect { persist }.to change { BusinessEntity.count }.by 1
      end
    end
  end

  # TODO: deprecate
  describe '#check_update' do
    let(:params) { { name: name, code: code } }
    subject { service.check_update(params) }

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

  # TODO: deprecate
  describe '#persist_update!' do
    let(:business_entity) { office.business_entities.first }
    subject { service.persist_update!(new_be) }

    describe 'when not sent a parameter' do
      let(:new_be) { nil }

      it { is_expected.to eq false }
    end

    describe 'when sent valid business_entity code change' do
      let(:new_be) { BusinessEntity.new(business_entity.attributes.merge(code: 'XY123', id: nil)) }

      it { is_expected.to eq true }

      describe 'persists the changes' do
        before { service.persist_update!(new_be) }

        it 'updates the existing business_entity' do
          business_entity.reload
          expect(business_entity.valid_to).not_to eq nil
        end

        it 'creates a new BusinessEntity' do
          expect(new_be.persisted?).to be true
        end
      end
    end

    describe 'when sent valid business_entity name change' do
      let(:new_name) { 'New name for BEC' }
      let(:new_be) { BusinessEntity.new(business_entity.attributes.merge(name: new_name)) }

      it { is_expected.to eq true }

      describe 'persists the changes' do
        before do
          service.persist_update!(new_be)
          business_entity.reload
        end

        it 'but does not update the valid_to attribute' do
          expect(business_entity.valid_to).to eq nil
        end

        it 'updates the existing business_entity name' do
          expect(business_entity.name).to eq new_name
        end
      end
    end
  end
end
