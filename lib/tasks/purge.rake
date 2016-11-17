namespace :online_applications do
  desc 'Purges un-used online_applications'
  task :purge, [] => :environment do
    begin
      purge = PurgeOnlineApplications.new
      number_of = purge.affected_records.size
      prior_to = purge.oldest_retention_date
      now = Time.zone.now
      puts "Running at: #{now}. Purging #{number_of} online_applications created before #{prior_to}"
      purge.now!
    rescue => err
      puts "online_applications error: #{err.message}"
      raise err
    end
  end
end
