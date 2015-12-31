namespace :run_sql do
  desc 'Execute local file, save your file with a .sql extension'
  task :from_file, [:file] => :environment do |_t, args|
    abort('Please submit filename') unless args[:file]
    abort('Please submit a .sql filename') unless args[:file].ends_with?('.sql')
    filename = args[:file].gsub('~', ENV['HOME'])
    puts "Reading #{filename}"
    instructions = File.read(filename)
    commands = instructions.split(';')
    command_count = commands.count
    ActiveRecord::Base.transaction do
      commands.each_with_index do |command, i|
        begin
          ActiveRecord::Base.connection.execute(command)
          puts "Executed command #{i + 1} of #{command_count}"
        rescue
          abort("Executing command #{i + 1} of #{command_count} failed: Transaction rolled-back")
        end
      end
    end
  end
end
