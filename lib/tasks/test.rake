# These tasks are needed by Jenkins pipeline

task test: :environment do
  system "bundle exec cucumber features/  --tags @smoke"
  # unless system("rake parallel:spec RAILS_ENV=test")
  #   raise "Rspec testing failed #{$?}"
  # end
  unless system "bundle exec rubocop"
    raise "Rubocop failed"
  end
end

namespace :test do
  task smoke: :environment do
    system "bundle exec cucumber features/  --tags @smoke"
  end

  task functional: :environment do
    system "bundle exec cucumber features/"
  end
end
