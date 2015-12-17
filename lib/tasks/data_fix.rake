namespace :data_fix do
  desc 'Fix for the 17th December incident'
  task december_17: :environment do
    sql_condition = [
      'DATE(created_at) = ? AND outcome IS NOT NULL AND reference IS NULL',
      '2015-12-17'
    ]

    count = Application.where(*sql_condition).count
    puts "Affected applications: #{count}"

    Application.where(*sql_condition).each do |application|
      puts "- fixing #{application.id}"

      application.completed_at = Time.zone.parse('2015-12-17 20:00:00')
      application.completed_by_id = application.user_id

      generator_output = ReferenceGenerator.new(application).attributes

      application.reference = generator_output[:reference]
      application.business_entity = generator_output[:business_entity]

      if application.part_payment.present?
        application.state = :waiting_for_part_payment
      elsif application.evidence_check.present?
        application.state = :waiting_for_evidence
      else
        application.state = :processed
      end

      application.save!
    end
  end
end
