class CorrectApplicationOutcomeBasedOnBenefitOverride < ActiveRecord::Migration[5.2]
  def change
    counter = 0
    BenefitOverride.all.each do |bo|
      if bo.application.outcome.nil?
        counter += 1
        puts ">" * 80
        puts "Application does not have outcome set: #{bo.application.id}"
        puts "Setting it now..."
        bo.application.update(outcome: (bo.correct ? 'full' : 'none'))
        puts "Application #{bo.application.id} has outcome set."
        puts "<" * 80
      end
    end
    puts "\n\n"
    puts "Total applications that didn't have outcome set based on BenefitOverride: #{counter}."
    puts "=" * 80
    puts "\n\n"
  end
end
