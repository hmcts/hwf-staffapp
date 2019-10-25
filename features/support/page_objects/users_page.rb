class UsersPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Staff'
    element :add_staff_link, 'a', text: 'Add staff'
    element :deleted_users, 'a', text: 'List deleted users'
  end
end
