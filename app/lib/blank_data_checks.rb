# # app/lib/blank_data_checks.rb

# # This script checks for blank fields in key models that are usually expected to be filled.
# # It inspects columns with `null: false` (mandatory fields) and reports records where these are blank.

# module BlankDataChecks
#   MODELS = [
#     Application,
#     OnlineApplication,
#     EvidenceCheck,
#     Detail,
#     Saving
#   ]

#   # Returns a hash: { ModelName => [{id: record_id, field: field_name, value: value}, ...], ... }
#   def self.check_blanks
#     results = {}

#     MODELS.each do |model|
#       next unless model.table_exists?

#       mandatory_columns = model.columns.select { |c| !c.null && c.name != model.primary_key }
#       blanks = []

#       mandatory_columns.each do |col|
#         # For string/text, blank means nil or empty string
#         # For other types, blank means nil
#         if [:string, :text].include?(col.type)
#           model.where("#{col.name} IS NULL OR #{col.name} = ''").find_each do |record|
#             blanks << { id: record.id, field: col.name, value: record.send(col.name) }
#           end
#         else
#           model.where("#{col.name} IS NULL").find_each do |record|
#             blanks << { id: record.id, field: col.name, value: record.send(col.name) }
#           end
#         end
#       end

#       results[model.name] = blanks unless blanks.empty?
#     end

#     results
#   end

#   # Prints a summary report to STDOUT
#   def self.report
#     results = check_blanks
#     if results.empty?
#       puts "No blank mandatory fields found."
#     else
#       results.each do |model, blanks|
#         puts "Model: #{model}"
#         blanks.each do |entry|
#           puts "  Record ID: #{entry[:id]}, Field: #{entry[:field]}, Value: #{entry[:value].inspect}"
#         end
#       end
#     end
#   end
# end

# # To run the report from Rails console:
# # BlankDataChecks.report
