class ReportBase
  require 'csv'
  require 'zip'
  attr_reader :zipfile_path

  def to_zip
    @csv_data = to_csv
    generate_file
  end

  def generate_file
    Zip::File.open(@zipfile_path, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream(@csv_file_name) { |f| f.write @csv_data }
    end
  end

  def format_dates(date_attribute)
    DateTime.parse(date_attribute.values.join('/')).utc
  end

end
