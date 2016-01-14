require 'csv'

def if_file_exist(file_path)
  if File.exist?(file_path)
    lines = []
    CSV.foreach(file_path, headers: true, skip_blanks: true, converters: [:integer]) do |line|
      lines << line.to_h.symbolize_keys
    end

    yield lines
  else
    puts "#{file_path} does not exist"
  end
end

namespace :bec_import do
  desc 'Prune unused BECs'
  task :prune, [:file_path] => :environment do |_, args|
    if_file_exist(args[:file_path]) do |lines|
      bec_import = BecImport.new(lines)
      bec_import.delete_unused
    end
  end

  desc 'Update existing BECs'
  task :update, [:file_path] => :environment do |_, args|
    if_file_exist(args[:file_path]) do |lines|
      bec_import = BecImport.new(lines)
      bec_import.update_existing
    end
  end
end
