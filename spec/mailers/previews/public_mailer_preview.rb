# Preview all emails at http://localhost:3000/rails/mailers/online_mailer
class PublicMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/online_mailer/confirmation
  def confirmation_online
    application = FactoryBot.build(:online_application, :with_reference, :with_email, :confirm_online)
    PublicMailer.submission_confirmation_online application
  end

  def confirmation_paper
    application = FactoryBot.build(:online_application, :with_reference, :with_email, :confirm_paper)
    PublicMailer.submission_confirmation_paper application
  end

  def refund_confirmation
    application = FactoryBot.build(:online_application, :with_reference, :with_email, :with_refund)
    PublicMailer.submission_confirmation_refund application
  end

  def et_confirmation
    application = FactoryBot.build(:online_application, :with_reference, :et, :with_email, :with_refund)
    PublicMailer.submission_confirmation_et application
  end
end
