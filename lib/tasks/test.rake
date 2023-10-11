# These tasks are needed by Jenkins pipeline

task test: :environment do
  unless system("rspec --format RspecJunitFormatter --out tmp/test/rspec.xml")
    raise "Rspec testing failed #{$?}"
  end
  # unless system("rake parallel:spec RAILS_ENV=test")
  #   raise "Rspec testing failed #{$?}"
  # end
  unless system "bundle exec rubocop"
    raise "Rubocop failed"
  end
  unless system "bundle exec cucumber features/  --tags @smoke"
    raise "Smoke tests failed"
  end

end

namespace :test do
  task smoke: :environment do
    puts "running smoke tests in main test rake"
  end

  task functional: :environment do
    unless system "bundle exec cucumber features/"
      raise "Smoke tests failed"
    end
  end
end
