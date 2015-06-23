require 'rails_helper'

RSpec.describe 'offices/edit', type: :view do
  let(:office) { assign(:office, create(:office)) }
  let(:jurisdictions) { assign(:jurisdictions, create_list(:jurisdiction, 4)) }

  it 'renders the edit office form' do

    jurisdictions
    office
    render
    expect(rendered).to have_xpath('//input[@name="office[jurisdiction_ids][]"]', count: jurisdictions.count + 1)

    assert_select 'form[action=?][method=?]', office_path(office), 'post' do
      assert_select 'input#office_name[name=?]', 'office[name]'

    end
  end
end
