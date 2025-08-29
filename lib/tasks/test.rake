# These tasks are needed by Jenkins pipeline

task test: :environment do
  unless system "bundle exec rubocop"
    raise "Rubocop failed"
  end

  unless system("rspec spec/lib/i18n_spec.rb --format RspecJunitFormatter --out tmp/test/rspec.xml")
    raise "Rspec testing failed #{$?}"
  end

  # running smoke test here because it's faster
  if system "bundle exec cucumber features/  --tags @smoke"
    puts "Smoke test passed"
  else
    raise "Smoke tests failed"
  end

end

namespace :test do
  task smoke: :environment do
    puts "Running smoke tests before the build after Rspec"
    # if system "bundle exec cucumber features/  --tags @smoke"
    #   puts "Smoke test passed"
    # else
    #   raise "Smoke tests failed"
    # end
  end

  task functional: :environment do
    if system "bundle exec cucumber features/"
      puts "Functional test passed"
    else
      raise "Functional tests failed"
    end
  end
end
