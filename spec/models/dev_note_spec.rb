require 'rails_helper'

RSpec.describe DevNote do
  describe 'associations' do
    it { is_expected.to belong_to(:notable) }
  end
end
