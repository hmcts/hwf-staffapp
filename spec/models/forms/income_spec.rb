require 'rails_helper'

RSpec.describe Forms::Income do
  params_list = %i[income dependents children]

  subject { described_class.new(hash) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end
end
