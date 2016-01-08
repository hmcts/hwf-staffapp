require 'rails_helper'

RSpec.describe 'offices/new', type: :view do

  include Devise::TestHelpers

  let(:manager) { create(:manager) }
  let!(:office) { assign(:office, Office.new) }
  let!(:jurisdictions) { assign(:jurisdictions, office.jurisdictions) }
  let!(:becs) { assign(:becs, office.business_entities) }

  it 'renders new office form' do
    sign_in manager
    render

    expect(rendered).to have_xpath('//input[@name="office[jurisdiction_ids][]"]', count: jurisdictions.count + 1)
    assert_select 'form[action=?][method=?]', offices_path, 'post' do
      assert_select 'input#office_name[name=?]', 'office[name]'
    end
  end
end
