require 'rails_helper'

RSpec.describe Forms::Search do
  subject(:form) { described_class.new }

  it { is_expected.to validate_presence_of(:reference) }
end
