# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
env :PATH, ENV['PATH']
set :output, error: 'log/cron_error.log', standard: 'log/cron.log'

job_type :rake, "cd :path && RAILS_ENV=production bundle exec rake :task :output"

every 1.day, at: '2am' do
  rake 'online_applications:purge'
end
