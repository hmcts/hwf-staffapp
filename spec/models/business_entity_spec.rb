require 'rails_helper'

RSpec.describe BusinessEntity, type: :model do
  it { is_expected.to belong_to(:office) }
  it { is_expected.to belong_to(:jurisdiction) }

  it { is_expected.to validate_presence_of(:office) }
  it { is_expected.to validate_presence_of(:jurisdiction) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to respond_to(:valid_from) }
  it { is_expected.to respond_to(:valid_to) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:valid_from) }

    describe 'valid_to' do
      let(:business_entity) { build_stubbed :business_entity }

      before { business_entity.valid_from = Time.zone.today }

      subject { business_entity }

      context 'when valid_to is before valid_from' do
        before { business_entity.valid_to = Time.zone.yesterday }
        it { is_expected.to be_invalid }
      end
    end
  end
end
