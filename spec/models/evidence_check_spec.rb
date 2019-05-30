require 'rails_helper'

describe EvidenceCheck, type: :model do
  it { is_expected.to belong_to(:application) }
  it { is_expected.to validate_presence_of(:application) }

  it { is_expected.to validate_presence_of(:expires_at) }
end
