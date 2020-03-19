class StaffPage < BasePage
  set_url '/users'

  section :content, '#content' do
    element :header, 'h1', text: 'Staff'
    element :filter_button, 'input[value="Filter"]'
    elements :result_row, '.govuk-table__row'
  end

  def set_up_multiple_users
    10.times do
      [:reader, :user, :admin_user, :manager].each { |user| FactoryBot.create(user) }
    end
  end

  def admin_on_staff_page
    sign_in_page.load_page
    sign_in_page.admin_account
    click_link 'View staff'
  end

  def filter
    staff_page.content.filter_button.click
  end
end
