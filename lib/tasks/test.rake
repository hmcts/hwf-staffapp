# These tasks are needed by Jenkins pipeline

task test: :environment do
  unless system "bundle exec rubocop"
    raise "Rubocop failed"
  end

  unless system("rspec --format RspecJunitFormatter --out tmp/test/rspec.xml")
    raise "Rspec testing failed #{$?}"
  end
end

namespace :test do
  # Smoke tests run against the deployed environment in TEST_URL. We only run
  # them against PR preview environments; they are skipped on AAT (and anything
  # that is not a preview) so they don't block the master-to-production deploy.
  task smoke: :environment do
    test_url = ENV['TEST_URL'].to_s

    unless test_url.include?('preview')
      puts "Skipping smoke tests - TEST_URL (#{test_url.empty? ? 'unset' : test_url}) is not a preview environment"
      next
    end

    ENV['RUN_SMOKE_TESTS'] = 'true'
    unless system "bundle exec cucumber -p smoke"
      raise "Smoke tests failed"
    end
  end

  task functional: :environment do
    ENV['RUN_SMOKE_TESTS'] = 'false'
    if system "bundle exec cucumber features/ --tags 'not @smoke --format pretty --format junit --out tmp/test/cucumber-functional'"
      puts "Functional test passed"
    else
      raise "Functional tests failed"
    end
  end

  # Local-only deep profiling to find what makes the RSpec suite slow. Combines
  # RSpec's --profile (slowest examples/groups) with test-prof's FactoryProf
  # (which factories cost the most time - usually the biggest offender). Pass a
  # path to scope it, e.g. bundle exec rake test:profile[spec/features]
  desc 'Profile the RSpec suite locally (slowest examples + factory usage)'
  task :profile, [:path] => :environment do |_task, args|
    path = args[:path] || 'spec'
    ENV['TEST_PROF'] = '1'
    ENV['FPROF'] = '1'
    system("bundle exec rspec #{path} --profile 25")
  end
end
