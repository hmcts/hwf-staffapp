require 'rails_helper'

RSpec.describe BusinessEntity, type: :model do
  it { is_expected.to belong_to(:office) }
  it { is_expected.to belong_to(:jurisdiction) }

  it { is_expected.to validate_presence_of(:office) }
  it { is_expected.to validate_presence_of(:jurisdiction) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
end
