RSpec.describe ChildrenHelper do
  let(:application) { build(:application) }

  describe '#age_band_value' do

    it 'return 0 if empty' do
      application.children_age_band = nil
      expect(helper.age_band_value(:one, application)).to eq 0
    end

    it 'return 0 if key not found' do
      application.children_age_band = { one: 2 }
      expect(helper.age_band_value(:three, application)).to eq 0
    end

    it 'return value for the key' do
      application.children_age_band = { one: 2 }
      expect(helper.age_band_value(:one, application)).to eq 2
    end
  end
end
