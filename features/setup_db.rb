Before do
    User.create!   name: 'Test User',
        email: 'user_1@digital.justice.gov.uk',
        password: 'password',
        password_confirmation: 'password',
        role: 'admin',
        office_id: 1,
        jurisdiction_id: nil
end