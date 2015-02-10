require 'rails_helper'

RSpec.describe "offices/index", type: :view do
  before(:each) do
    assign(:offices, [
      Office.create!(
        :name => "Name"
      ),
      Office.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of offices" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
