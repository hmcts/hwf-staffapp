module Views
  module Reports
    class ApplicantsPerFyExport
      require 'csv'
      require 'zip'

      attr_reader :result

      OUTCOMES = ['none', 'part', 'full'].freeze

      def initialize(fy_start, fy_end)
        @date_from = "#{fy_start}-04-01 00:00"
        @date_to = "#{fy_end}-03-31 23:59"
        @csv_file_name = "applicants-#{fy_start}-#{fy_end}-fy.csv"
        @zipfile_path = "tmp/applicants-#{fy_start}-#{fy_end}-fy.csv.zip"

        @applicants = laod_applicants
        @jurisdictions = Jurisdiction.pluck(:name).sort
        hash_with_counts
      end

      def to_zip
        @csv_data = to_csv
        generate_file
      end

      def generate_file
        Zip::File.open(@zipfile_path, Zip::File::CREATE) do |zipfile|
          zipfile.get_output_stream(@csv_file_name) { |f| f.write @csv_data }
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def to_csv
        CSV.generate do |csv|
          csv << csv_headers

          @result.each do |key, value|
            csv << [key.split("-")[0], key.split("-")[1], key.split("-")[2], value["count"],
                    get_hash_values(@jurisdictions, value["jurisdiction"]),
                    get_hash_values(OUTCOMES, value["decision"])].flatten
          end
        end
      end

      private

      def csv_headers
        ["First Name", "Last Name", "Date of Birth", "Number of applications"] + @jurisdictions + OUTCOMES
      end

      def get_hash_values(default_list, row)
        default_list.map { |j| row.key?(j) ? row[j] : 0 }
      end

      def hash_with_counts
        @result = {}
        @applicants.each do |h|
          key = [h["first_name"], h["last_name"], h["date_of_birth"]].join("-")
          if @result[key].nil?
            @result[key] = Hash.new(0)
            @result[key]["jurisdiction"] = Hash.new(0)
            @result[key]["jurisdiction"][h["name"]] = 1
            @result[key]["decision"] = Hash.new(0)
            @result[key]["decision"][h["decision"]] = 1
            @result[key]["count"] = 1
          else
            @result[key]["jurisdiction"][h["name"]] += 1
            @result[key]["decision"][h["decision"]] += 1
            @result[key]["count"] += 1
          end
        end
      end

      def laod_applicants
        sql = "SELECT a.first_name, a.last_name, a.date_of_birth, j.name, a.application_id, ap.decision
             FROM applicants a
             INNER JOIN applications ap ON a.application_id = ap.id
             left join details d ON ap.id = d.application_id
             left join jurisdictions j ON j.id = d.jurisdiction_id
             WHERE ap.state = 3
             AND ap.updated_at BETWEEN '#{@date_from}' AND '#{@date_to}'
         	ORDER BY a.first_name, a.last_name, a.date_of_birth"

        @applicants = ActiveRecord::Base.connection.execute(sql)
      end

      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
