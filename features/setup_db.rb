Before do
  User.create!   name: 'Test Admin',
                 email: 'user_1@digital.justice.gov.uk',
                 password: 'password',
                 password_confirmation: 'password',
                 role: 'admin',
                 office_id: 1,
                 jurisdiction_id: nil

  User.create!   name: 'Test User',
                 email: 'user_2@digital.justice.gov.uk',
                 password: 'password',
                 password_confirmation: 'password',
                 role: 'user',
                 office_id: 1,
                 jurisdiction_id: nil

  User.create!   name: 'Test Manager',
                 email: 'user_3@digital.justice.gov.uk',
                 password: 'password',
                 password_confirmation: 'password',
                 role: 'manager',
                 office_id: 1,
                 jurisdiction_id: nil
end
