require 'rails_helper'

RSpec.describe BenefitOverride do
  it { is_expected.to validate_presence_of(:application) }
end
