# coding: utf-8

require 'rails_helper'

RSpec.describe Views::OfficeBusinessEntityState do
  subject(:view) { described_class.new(office, jurisdiction) }

  let(:office) { create :office }
  let(:jurisdiction) { create :jurisdiction }
  let!(:business_entity) { create :business_entity, office: office, jurisdiction: jurisdiction }

  it { is_expected.to respond_to(:jurisdiction_id) }
  it { is_expected.to respond_to(:jurisdiction_name) }
  it { is_expected.to respond_to(:business_entity_id) }
  it { is_expected.to respond_to(:business_entity_code) }
  it { is_expected.to respond_to(:business_entity_sop_code) }
  it { is_expected.to respond_to(:business_entity_name) }

  describe '#jurisdiction_id' do
    subject { view.jurisdiction_id }

    it { is_expected.to eq jurisdiction.id }
  end

  describe '#jurisdiction_name' do
    subject { view.jurisdiction_name }

    it { is_expected.to eq jurisdiction.name }
  end

  context 'when a business_entity exists' do
    describe '#business_entity_id' do
      subject { view.business_entity_id }

      it { is_expected.to eq business_entity.id }
    end

    describe '#business_entity_code' do
      subject { view.business_entity_code }

      it { is_expected.to eq business_entity.be_code }
    end

    describe '#business_entity_name' do
      subject { view.business_entity_name }

      it { is_expected.to eq business_entity.name }
    end
  end

  context 'when a business_entity does not exist' do
    before { business_entity.delete }

    describe '#business_entity_id' do
      subject { view.business_entity_id }

      it { is_expected.to eq nil }
    end

    describe '#business_entity_code' do
      subject { view.business_entity_code }

      it { is_expected.to eq nil }
    end

    describe '#business_entity_name' do
      subject { view.business_entity_name }

      it { is_expected.to eq nil }
    end
  end

  describe '#status' do
    subject { view.status }

    before do
      office.business_entities.delete_all
      OfficeJurisdiction.delete_all
    end

    context 'when a business_entity object exists' do
      before { create :business_entity, office: office, jurisdiction: jurisdiction }

      context 'it is currently in use by the office' do
        before { create :office_jurisdiction, office: office, jurisdiction: jurisdiction }

        it { is_expected.to eq 'edit' }
      end

      context 'it is not currently in use by the office' do
        it { is_expected.to eq 'delete' }
      end
    end

    context 'when a business_entity object does not exist' do
      it { is_expected.to eq 'add' }
    end
  end

  describe '#sequence' do
    subject { view.sequence }

    before do
      office.business_entities.delete_all
      OfficeJurisdiction.delete_all
    end

    context 'when a business_entity object exists' do
      before { create :business_entity, office: office, jurisdiction: jurisdiction }

      context 'it is currently in use by the office' do
        before { create :office_jurisdiction, office: office, jurisdiction: jurisdiction }

        it { is_expected.to eq 1 }
      end

      context 'it is not currently in use by the office' do
        it { is_expected.to eq 0 }
      end
    end

    context 'when a business_entity object does not exist' do
      it { is_expected.to eq 2 }
    end
  end
end
