class OnlineMailer < ApplicationMailer

  def confirmation(application)
    standard_attachments
    @application = application
    mail_with_subject @application.email_address, t('email.confirmation.subject')
  end

  def refund_confirmation(application)
    standard_attachments
    @application = application
    mail_with_subject @application.email_address, t('email.refund.subject')
  end

  private

  def standard_attachments
    attachments.inline['icon-important.png'] = File.read('app/assets/images/icon-important.png')
    attachments.inline['crest.png'] = File.read('app/assets/images/crest.png')
    attachments.inline['moj_logo.png'] = File.read('app/assets/images/moj_logotype_email.png')
  end

  def mail_with_subject(to, subject)
    mail to: to, subject: subject
  end
end
