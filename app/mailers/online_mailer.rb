class OnlineMailer < ApplicationMailer

  def confirmation(application)
    attachments.inline['icon-important.png'] = File.read('app/assets/images/icon-important.png')
    attachments.inline['crest.png'] = File.read('app/assets/images/crest.png')
    attachments.inline['moj_logo.png'] = File.read('app/assets/images/moj_logo_small_png24.png')
    @application = application
    mail_with_subject @application.email_address, 'Help with Fees confirmation'
  end

  private

  def mail_with_subject(to, subject)
    mail to: to, subject: subject
  end
end
