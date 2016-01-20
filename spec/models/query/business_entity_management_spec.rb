require 'rails_helper'

RSpec.describe Query::BusinessEntityManagement, type: :model do
  let(:office1) { create :office }
  let(:office2) { create :office }

  subject(:query) { described_class.new(office1) }

  describe '#jurisdictions' do
    subject { query.jurisdictions.count }

    it { is_expected.to eq 2 }
  end
end
