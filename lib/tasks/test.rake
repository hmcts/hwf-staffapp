# These tasks are needed by Jenkins pipeline

task test: :environment do
  unless system("rspec -t ~smoke --format RspecJunitFormatter --out tmp/test/rspec.xml")
    raise "Rspec testing failed #{$?}"
  end
  # unless system("rake parallel:spec RAILS_ENV=test")
  #   raise "Rspec testing failed #{$?}"
  # end
  unless system "bundle exec rubocop"
    raise "Rubocop failed"
  end
  # unless system "bundle exec cucumber features/  --tags @smoke"
  #   raise "Smoke tests failed"
  # end
  # unless system "rake parallel:features CAPYBARA_SERVER_PORT=random RAILS_ENV=test"
  #   raise "Functional tests failed"
  # end
end

namespace :test do
  task smoke: :environment do
    puts "Smoke tests run in normal test rake"
  end

  task functional: :environment do
    puts "Functional tests run in normal test rake"
  end
end
