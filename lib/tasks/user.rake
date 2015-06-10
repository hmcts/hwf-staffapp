namespace :user do

  desc 'Create an admin user with given email, password and role.'
  task :create, [:email, :password, :role, :name] => :environment do |_t, args|
    office = Office.first
    args.with_defaults(email: 'admin@hmcts.gsi.gov.uk',
                       name: 'Admin User',
                       password: '123456789',
                       role: 'admin')
    email, password, role, name = args[:email], args[:password],  args[:role], args[:name]
    puts "Creating user with email: #{email}, password #{password} and role: #{role}"

    User.create!(email: email,
                 password: password,
                 password_confirmation: password,
                 role: role,
                 name: name,
                 office_id: office.id)

    puts 'User created!'
  end
end
