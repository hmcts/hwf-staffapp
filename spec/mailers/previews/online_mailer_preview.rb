# Preview all emails at http://localhost:3000/rails/mailers/online_mailer
class OnlineMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/online_mailer/confirmation
  def confirmation
    application = FactoryGirl.create(:online_application, :with_reference, :with_email)
    OnlineMailer.confirmation application
  end
end
