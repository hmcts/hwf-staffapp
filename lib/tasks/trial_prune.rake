namespace :trial_prune do
  desc 'Delete applications for an office'
  task :office_applications, [:office_id] => :environment do |_, args|
    office = Office.find(args[:office_id])

    ActiveRecord::Base.transaction do
      office.applications.each do |application|
        application.applicant.delete
        application.detail.delete

        application.benefit_checks.delete_all unless application.benefit_checks.empty?
        application.evidence_check.delete if application.evidence_check
        application.part_payment.delete if application.part_payment
        application.benefit_override.delete if application.benefit_override

        application.delete
      end
    end
  end

  desc 'Delete applications created by a user'
  task :user_applications, [:user_id] => :environment do |_, args|
    user = User.find(args[:user_id])

    ActiveRecord::Base.transaction do
      Application.where(user: user).each do |application|
        application.applicant.delete
        application.detail.delete

        application.benefit_checks.delete_all unless application.benefit_checks.empty?
        application.evidence_check.delete if application.evidence_check
        application.part_payment.delete if application.part_payment
        application.benefit_override.delete if application.benefit_override

        application.delete
      end
    end
  end

  desc 'Delete users with @digital.justice.gov.uk email'
  task digital_users: :environment do
    User.with_deleted.where('email LIKE ?', '%@digital.justice.gov.uk').delete_all
  end
end
