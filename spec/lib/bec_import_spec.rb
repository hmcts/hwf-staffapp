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
        office_id: office.id,
        jurisdiction_id: jurisdiction1,
        code: 'BE001',
        description: 'desc BE 001'
      },
      {
        office_id: office.id,
        jurisdiction_id: jurisdiction4,
        code: 'BE004',
        description: 'desc BE 004'
      }
    ]
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

  describe '#update_existing'
end
