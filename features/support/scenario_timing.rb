# Prints the slowest scenarios and features when CUCUMBER_TIMING is set (CI) - see CHANGELOG.md
if ENV['CUCUMBER_TIMING'].present?
  scenario_timings = []

  Before do
    @scenario_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  After do |scenario|
    seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @scenario_started_at
    scenario_timings << { location: scenario.location.to_s, name: scenario.name, seconds: seconds }
  end

  at_exit do
    next if scenario_timings.empty?

    puts "\nSlowest 20 scenarios:"
    scenario_timings.max_by(20) { |timing| timing[:seconds] }.each do |timing|
      puts "  #{timing[:seconds].round(2)}s  #{timing[:location]}  #{timing[:name]}"
    end

    puts "\nTime per feature file:"
    feature_totals = scenario_timings.group_by { |timing| timing[:location].split(':').first }.
                     transform_values { |timings| timings.sum { |timing| timing[:seconds] } }
    feature_totals.sort_by { |_file, seconds| -seconds }.first(20).each do |file, seconds|
      puts "  #{seconds.round(2)}s  #{file}"
    end
  end
end
