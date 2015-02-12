require 'spec_helper'

RSpec.describe "home/index.html.slim", type: :view do
  it 'should contain our dashboard header' do
    render
    expect(rendered).to include('Dashboard')
  end
end
