class OnlineMailer < ApplicationMailer

  def confirmation(application)
    attachments.inline['icon-important.png'] = File.read('app/assets/images/icon-important.png')
    @application = application
    mail_with_subject @application.email_address, 'Help with Fees confirmation'
  end

  private

  def mail_with_subject(to, subject)
    mail to: to, subject: subject
  end
end
