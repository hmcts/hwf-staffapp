Before do

  Jurisdiction.create![
    { name: 'County', abbr: nil },
    { name: 'Family', abbr: nil },
    { name: 'High', abbr: nil },
    { name: 'Insolvency', abbr: nil },
    { name: 'Magistrates', abbr: nil },
    { name: 'Probate', abbr: nil },
    { name: 'Employment', abbr: nil },
    { name: 'Gambling', abbr: nil },
    { name: 'Gender recognition', abbr: nil },
    { name: 'Immigration (first-tier)', abbr: nil },
    { name: 'Immigration (upper)', abbr: nil },
    { name: 'Property', abbr: nil }]

  office = Office.create! name: 'Digital',
                          entity_code: 'MA105',
                          jurisdiction_ids: [1]

  User.create!   name: 'Test Admin',
                 email: 'user_1@digital.justice.gov.uk',
                 password: 'password',
                 password_confirmation: 'password',
                 role: 'admin',
                 office_id: office.id,
                 jurisdiction_id: nil

  User.create!   name: 'Test User',
                 email: 'user_2@digital.justice.gov.uk',
                 password: 'password',
                 password_confirmation: 'password',
                 role: 'user',
                 office_id: office.id,
                 jurisdiction_id: nil

  User.create!   name: 'Test Manager',
                 email: 'user_3@digital.justice.gov.uk',
                 password: 'password',
                 password_confirmation: 'password',
                 role: 'manager',
                 office_id: office.id,
                 jurisdiction_id: nil

  Application.create! office_id: office.id

  Applicant.create! title: 'Mr',
                    application_id: Application.first.id,
                    first_name: 'Test',
                    last_name: 'Test',
                    date_of_birth: Time.zone.today - 20.years,
                    ni_number: 'AB123456C',
                    married: false

end
