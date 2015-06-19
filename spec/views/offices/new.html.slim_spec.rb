require 'rails_helper'

RSpec.describe 'offices/new', type: :view do

  before(:each) { assign(:office, Office.new) }
  let(:jurisdictions) { assign(:jurisdictions, create_list(:jurisdiction, 4)) }

  it 'renders new office form' do

    jurisdictions
    render

    expect(rendered).to have_xpath('//input[@name="office[jurisdiction_ids][]"]', count: jurisdictions.count + 1)
    assert_select 'form[action=?][method=?]', offices_path, 'post' do
      assert_select 'input#office_name[name=?]', 'office[name]'
    end
  end
end
