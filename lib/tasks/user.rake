namespace :user do

  desc 'Create an admin user with given email, password and role.'
  task :create, [:email, :password, :role] => :environment do |t, args|
    args.with_defaults(email: 'admin@admin.com', password: '123456789', role: 'user')
    email, password, role = args[:email], args[:password],  args[:role]
    puts "Creating user with email: #{email}, password #{password} and role: #{role}"

    User.create!(email: email,
                 password: password,
                 password_confirmation: password,
                 role: role
    )

    puts 'User created!'
  end
end