class ApplicationMailer < ActionMailer::Base
  default from: Settings.mail.from
  layout 'mailer'

  def dwp_is_down_notifier
    to = Settings.mail.dwp_notification_alert
    mail(to: to, subject: t('email.dwp_alert_notification.subject',
      environment: ENV['ENV'])) do |format|
        format.text { render plain: t('email.dwp_alert_notification.message') }
      end
  end
end
