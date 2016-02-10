require 'rails_helper'

RSpec.describe I18n do
  it 'interpolates as usual' do
    expect(described_class.interpolate('Show %{model}', model: 'Office')).to eql 'Show Office'
  end

  it 'supports method execution' do
    expect(described_class.interpolate("Show %{model.downcase}", model: 'Office')).to eql 'Show office'
  end
end
