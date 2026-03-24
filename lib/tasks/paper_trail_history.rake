# rubocop:disable Rails/RakeEnvironment, Lint/EmptyBlock
desc "Show change history for an application. Usage: rake paper_trail APPLICATION_ID"
task :paper_trail, [:application_id] => :environment do |_t, args|
  application_id = args[:application_id] || ARGV[1]

  abort "Usage: rake paper_trail APPLICATION_ID" if application_id.blank?

  # Prevent rake from interpreting the application_id as a task name
  if ARGV.length > 1
    ARGV[1..].each { |a| task(a.to_sym) {} }
  end

  versions = PaperTrail::Version.
             where(item_type: "Application", item_id: application_id).
             order(:created_at)

  if versions.empty?
    puts "No versions found for Application #{application_id}"
    next
  end

  state_names = {
    0 => "created",
    1 => "waiting_for_evidence",
    2 => "waiting_for_part_payment",
    3 => "processed",
    4 => "deleted"
  }.freeze

  puts "=" * 80
  puts "Paper Trail History for Application ##{application_id}"
  puts "Total versions: #{versions.count}"
  puts "=" * 80

  versions.each_with_index do |version, index|
    puts ""
    puts "-" * 80
    puts "Version #{index + 1} | Event: #{version.event.upcase} | #{version.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "User (whodunnit): #{version.whodunnit || 'system'}"
    puts "-" * 80

    if version.object_changes.present?
      changes = YAML.safe_load(
        version.object_changes,
        permitted_classes: [
          ActiveSupport::TimeWithZone,
          ActiveSupport::TimeZone,
          Time,
          BigDecimal,
          Date,
          Symbol
        ],
        aliases: true
      )

      if changes.is_a?(Hash)
        changes.each do |field, values|
          next if field == "updated_at"

          old_val, new_val = values

          old_val = format_value(field, old_val, state_names)
          new_val = format_value(field, new_val, state_names)

          puts "  #{field}:"
          puts "    from: #{old_val}"
          puts "      to: #{new_val}"
        end
      else
        puts "  (could not parse object_changes)"
      end
    elsif version.object.present?
      puts "  [Snapshot only — no field-level changes recorded]"
    else
      puts "  [No change data available]"
    end
  end

  puts ""
  puts "=" * 80
end
# rubocop:enable Rails/RakeEnvironment, Lint/EmptyBlock

def format_value(field, value, state_names)
  return "(empty)" if value.nil?

  if field == "state" && value.is_a?(Integer)
    "#{value} (#{state_names.fetch(value, 'unknown')})"
  elsif value.is_a?(ActiveSupport::TimeWithZone) || value.is_a?(Time)
    value.strftime("%Y-%m-%d %H:%M:%S")
  elsif value.is_a?(BigDecimal)
    value.to_s("F")
  else
    value.to_s
  end
end
