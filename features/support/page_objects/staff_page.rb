class StaffPage < BasePage
  set_url '/users'

  section :content, '#content' do
    element :header, 'h1', text: 'Staff'
    element :office_result, 'td.govuk-table__cell:nth-child(4)'
    element :activity_flag, 'td.govuk-table__cell:nth-child(6)', text: 'Active'
    elements :result_row, '.govuk-table__row'
    element :office_filter, '#office'
  end

  def set_up_multiple_users
    [:reader, :user, :admin_user, :manager].each { |user| FactoryBot.create(user) }
  end

  def manager_on_staff_page
    sign_in_page.load_page
    sign_in_page.manager_account
    click_link 'View staff'
  end

  def admin_on_staff_page
    sign_in_page.load_page
    sign_in_page.admin_account
    click_link 'View staff'
  end
end
