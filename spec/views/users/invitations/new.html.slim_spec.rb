require 'rails_helper'

RSpec.describe 'users/invitations/new', type: :view do

  before do
    create_list :office, 2
    assign(:offices, Office.all)
  end
  context 'as an admin' do
    let(:admin) { FactoryBot.create :admin_user }
    before do
      assign(:user, User.new)
      assign(:roles, User::ROLES)
      sign_in admin
      render
    end
    describe 'renders new user invite form with three roles' do
      it { expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'Mi') }
      it { expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'Admin') }
      it { expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'Manager') }
      it { expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'User') }
    end
    describe 'renders the office as a drop down' do
      it { expect(rendered).to have_xpath("//select[@name='user[office_id]']") }
      it { expect(rendered).to have_xpath("//select[@name='user[office_id]']/option") }
    end

  end

  context 'as a manager' do
    let(:manager) { FactoryBot.create :manager }

    before do
      assign(:user, User.new)
      assign(:roles, ['user', 'manager'])
      sign_in manager
      render
    end
    describe 'renders new user invite form with three roles' do
      it { expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'Manager') }
      it { expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'User') }
      it { expect(rendered).not_to have_xpath("//select[@name='user[role]']/option", text: 'Admin') }
      it { expect(rendered).not_to have_xpath("//select[@name='user[role]']/option", text: 'Mi') }
    end
    it 'does not render the office name' do
      expect(rendered).not_to include(manager.office.name)
    end
    describe 'adds a hidden field for office id' do
      it { expect(rendered).not_to have_xpath("//select[@name='user[office_id]']") }
      it { expect(rendered).to have_xpath("//input[@name='user[office_id]' and @value='#{manager.office.id}']", visible: false) }
    end
  end
end
