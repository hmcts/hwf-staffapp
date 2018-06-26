# coding: utf-8

require 'rails_helper'

describe BusinessEntityService do
  subject { service }

  let!(:office) { create :office }
  let!(:jurisdiction) { office.jurisdictions[0] }
  let(:service) { described_class.new(office, jurisdiction) }

  describe 'when initialized with the correct variables' do
    it { is_expected.to be_a_kind_of described_class }
  end

  describe '#build_new' do
    subject(:built_new) { service.build_new(params) }

    let(:params) { { name: name, be_code: be_code, sop_code: sop_code } }

    describe 'when sent correct values' do
      let(:name) { 'test-jurisdiction' }
      let(:be_code) { nil }
      let(:sop_code) { '123456789' }

      it { is_expected.to be_a_kind_of BusinessEntity }

      it 'does not persist the object' do
        expect(built_new.persisted?).to be false
      end

      it 'returns a valid object' do
        expect(built_new.valid?).to be true
      end
    end

    describe 'when sent incorrect values' do
      let(:name) { 'test-jurisdiction' }
      let(:be_code) { nil }
      let(:sop_code) { nil }

      it 'does not persist the object' do
        expect(built_new.persisted?).to be false
      end

      it 'returns an invalid object' do
        expect(built_new.valid?).to be false
      end
    end
  end

  describe '#build_update' do
    subject(:build_update) { service.build_update(params) }

    let(:params) { { name: name, be_code: be_code, sop_code: sop_code } }
    let(:business_entity) { BusinessEntity.current_for(office, jurisdiction) }

    describe 'when sent new be_code' do
      let(:name) { 'test-jurisdiction' }
      let(:be_code) { business_entity.be_code.reverse }
      let(:sop_code) { business_entity.sop_code }

      it { is_expected.to be_a_kind_of BusinessEntity }

      it 'returns a new, non-persisted object' do
        expect(build_update.persisted?).to be true
      end

      it 'returns a valid object' do
        expect(build_update.valid?).to be true
      end

      it 'has the ID of the existing business_entity' do
        expect(build_update.id).to eq business_entity.id
      end
    end

    describe 'when sent new sop_code' do
      let(:name) { 'test-jurisdiction' }
      let(:be_code) { business_entity.be_code }
      let(:sop_code) { business_entity.sop_code.reverse }

      it { is_expected.to be_a_kind_of BusinessEntity }

      it 'returns a new, non-persisted object' do
        expect(build_update.persisted?).to be false
      end

      it 'returns a valid object' do
        expect(build_update.valid?).to be true
      end

      it 'has no ID' do
        expect(build_update.id).to be nil
      end
    end

    describe 'when sent an updated name only' do
      let(:name) { 'test-jurisdiction' }
      let(:be_code) { business_entity.be_code }
      let(:sop_code) { business_entity.sop_code }

      it { is_expected.to be_a_kind_of BusinessEntity }

      it 'returns the existing persisted object' do
        expect(build_update.persisted?).to be true
      end

      it 'returns a valid object' do
        expect(build_update.valid?).to be true
      end

      it 'has the ID of the existing business_entity' do
        expect(build_update.id).to eq business_entity.id
      end
    end

    describe 'when sent incorrect values' do
      let(:name) { 'test-jurisdiction' }
      let(:be_code) { nil }
      let(:sop_code) { nil }

      it 'does not persist the object' do
        expect(build_update.persisted?).to be false
      end

      it 'returns an invalid object' do
        expect(build_update.valid?).to be false
      end
    end
  end

  describe '#build_deactivate' do
    subject(:build_deactivate) { service.build_deactivate }

    it { is_expected.to be_a_kind_of BusinessEntity }

    it 'returns a persisted object' do
      expect(build_deactivate.persisted?).to be true
    end

    it 'returns a valid object' do
      expect(build_deactivate.valid?).to be true
    end

    it 'has no valid_to' do
      expect(build_deactivate.valid_to).not_to be nil
    end
  end

  describe '#persist!' do
    subject(:persist) { service.persist! }

    let!(:business_entity) { BusinessEntity.current_for(office, jurisdiction) }

    context 'when persisting a new object' do
      before { service.build_new(name: 'Test', sop_code: '123456789') }

      it 'creates a new business_entity' do
        expect { persist }.to change { BusinessEntity.count }.by 1
      end

      it 'the business_entity has no error messages' do
        service.persist!
        expect(service.business_entity.errors.messages).to be_blank
      end
    end

    context 'when persisting a new object with invalid data' do
      before { service.build_new(name: '', sop_code: '123456789') }

      it 'the business_entity has no error messages' do
        service.persist!
        expect(service.business_entity.errors.messages).to eql(name: ["can't be blank"])
      end

      it 'return false' do
        expect(service.persist!).to be_falsey
      end
    end

    context 'when persisting an update' do
      context 'that changes the code' do
        before { service.build_update(name: 'Test', sop_code: '987654321') }

        it 'creates a new business_entity' do
          expect { persist }.to change { BusinessEntity.count }.by 1
        end

        it 'return true if no errors' do
          expect(service.persist!).to be_truthy
        end

        it 'sets the valid_to date of the existing business_entity' do
          service.persist!
          business_entity.reload
          expect(business_entity.valid_to).not_to eq nil
        end

        it 'the business_entity has no error messages' do
          service.persist!
          expect(service.business_entity.errors.messages).to be_blank
        end
      end

      context 'invalid data' do
        before { service.build_update(name: '', sop_code: '987654321') }

        it 'return false if fails to persist' do
          expect(service.persist!).to be_falsey
        end

        it 'the business_entity has the error messages' do
          service.persist!
          expect(service.business_entity.errors.messages).to eql(name: ["can't be blank"])
        end
      end

      context 'that does not change the code' do
        it 'creates a new business_entity' do
          expect { service.persist! }.not_to change { BusinessEntity.count }
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

      it 'the business_entity has no error messages' do
        service.persist!
        expect(service.business_entity.errors.messages).to be_blank
      end
    end
  end
end
