require 'spec_helper'

RSpec.describe "home/index.html.slim", type: :view do
  it 'should contain our header' do
    render
    expect(rendered).to include('Your home page here')
  end
end
