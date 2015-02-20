require 'rails_helper'

RSpec.describe 'offices/edit', type: :view do
  let(:office) { assign(:office, FactoryGirl.create(:office)) }

  it 'renders the edit office form' do
    office
    render
    assert_select 'form[action=?][method=?]', office_path(office), 'post' do

      assert_select 'input#office_name[name=?]', 'office[name]'
    end
  end
end
