require 'rails_helper'

RSpec.describe BecImport do
  subject(:import) { described_class.new(lines) }

  let!(:jurisdiction1) { create(:jurisdiction) }
  let!(:jurisdiction2) { create(:jurisdiction) }
  let!(:jurisdiction3) { create(:jurisdiction) }
  let!(:jurisdiction4) { create(:jurisdiction) }
  let!(:office) { create(:office, jurisdictions: [jurisdiction1]) }
  let!(:business_entity1) { office.business_entities.first }
  let!(:business_entity2) { create :business_entity, office: office, jurisdiction: jurisdiction2 }
  let!(:business_entity3) { create :business_entity, office: office, jurisdiction: jurisdiction3 }
  let!(:business_entity4) { create :business_entity, office: office, jurisdiction: jurisdiction4 }
  let!(:application) { create :application, business_entity: business_entity3 }

  let(:lines) do
    [
      {
        office_id: office.id.to_s,
        jurisdiction_id: jurisdiction1.id.to_s,
        code: 'BE001',
        description: 'desc BE 001'
      },
      {
        office_id: office.id,
        jurisdiction_id: jurisdiction4.id,
        code: '',
        description: ''
      }
    ]
  end

  describe '#initialize' do
    context 'for valid input lines' do
      it 'returns BecImport instance' do
        is_expected.to be_a(described_class)
      end
    end

    context 'when any line is missing any of the required fields' do
      before do
        lines[1].delete(:code)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete_unused' do
    subject { import.delete_unused }

    before do
      subject
    end

    it 'removes business entity which is not associated to an office or any application' do
      expect { business_entity2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'presents business entity which is associated to an office' do
      expect(business_entity1).to eql(business_entity1)
    end

    it 'presents business entity which is associated to any application' do
      expect(business_entity3).to eql(business_entity3)
    end

    it 'presents business entity which is in the input lines' do
      expect(business_entity4).to eql(business_entity4)
    end
  end

  describe '#update_existing' do
    subject { import.update_existing }

    before do
      subject
    end

    it 'updates code and description when both present' do
      reloaded1 = business_entity1.reload

      expect(reloaded1.code).to eql('BE001')
      expect(reloaded1.name).to eql('desc BE 001')
    end

    it 'does not update business entity when code and description are not present' do
      reloaded4 = business_entity4.reload

      expect(reloaded4.code).to eql(business_entity4.code)
      expect(reloaded4.name).to eql(business_entity4.name)
    end

    it 'ignores other existing business entities' do
      reloaded2 = business_entity2.reload
      reloaded3 = business_entity3.reload

      expect(reloaded2.code).to eql(business_entity2.code)
      expect(reloaded2.name).to eql(business_entity2.name)
      expect(reloaded3.code).to eql(business_entity3.code)
      expect(reloaded3.name).to eql(business_entity3.name)
    end
  end
end
