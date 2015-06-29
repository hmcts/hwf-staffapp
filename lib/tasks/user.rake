namespace :user do

  desc 'Create an admin user with given email, password and role.'
  task :create, [:email, :password, :role, :name] => :environment do |_t, args|

    Rake::Task["db:seed"].execute if Office.count == 0

    args.with_defaults(email: 'admin@hmcts.gsi.gov.uk',
                       name: 'Admin User',
                       password: '123456789',
                       role: 'admin')

    puts "Creating user with email: #{args[:email]}, password #{args[:password]} \
and role: #{args[:role]}"

    User.create!(email: args[:email],
                 password: args[:password],
                 password_confirmation: args[:password],
                 role: args[:role],
                 name: args[:name],
                 office_id: Office.first.id)

    puts 'User created!'
  end
end
