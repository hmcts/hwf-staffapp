require 'rails_helper'

RSpec.describe Saving, type: :model do
  let(:fee) { 50 }
  let(:application) { create :application }
  let(:detail) { create :detail, application: application, fee: fee }
  subject(:savings) { create :saving, application: application }

  it { is_expected.to belong_to(:application) }
  it { is_expected.to validate_presence_of(:application) }

end
