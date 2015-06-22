require 'rails_helper'

RSpec.describe Jurisdiction, type: :model do

  let(:jurisdiction) { create(:jurisdiction) }

  it 'passes factory build' do
    expect(jurisdiction).to be_valid
  end

  describe 'validation' do
    it 'enforces presence of name' do
      jurisdiction.name = nil
      expect(jurisdiction).to be_invalid
    end
    it 'enforces unique name' do
      new = build(:jurisdiction, name: jurisdiction.name)
      expect(new).to be_invalid
    end
    it 'enforces unique abbreviation' do
      new = build(:jurisdiction, abbr: jurisdiction.abbr)
      expect(new).to be_invalid
    end
    it 'allows multiple empty abbreviations' do
      create(:jurisdiction, name: 'High Court', abbr: nil)
      new = create(:jurisdiction, name: 'County Court', abbr: nil)
      expect(jurisdiction).to be_valid
      expect(new).to be_valid
    end
  end

  describe 'display' do
    it 'returns abbr if set' do
      expect(jurisdiction.display).to eql(jurisdiction.abbr)
    end
    it 'returns name if abbreviation is empty' do
      jurisdiction.abbr = nil
      expect(jurisdiction.display).to eql(jurisdiction.name)
    end
  end
end
