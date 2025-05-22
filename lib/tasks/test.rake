# These tasks are needed by Jenkins pipeline

task test: :environment do
  unless system "bundle exec rubocop"
    raise "Rubocop failed"
  end
  # rubocop:disable Layout/LineLength
  unless system("rspec spec/features/band_based_calculations/saving_over_threshold_spec.rb --format RspecJunitFormatter --out tmp/test/rspec.xml")
    raise "Rspec testing failed #{$?}"
  end
  # rubocop:enable Layout/LineLength
end

namespace :test do
  task smoke: :environment do
    if system "bundle exec cucumber features/  --tags @smoke"
      puts "Smoke test passed"
    else
      raise "Smoke tests failed"
    end
  end

  task functional: :environment do
    if system "bundle exec cucumber features/"
      puts "Functional test passed"
    else
      raise "Functional tests failed"
    end
  end
end
