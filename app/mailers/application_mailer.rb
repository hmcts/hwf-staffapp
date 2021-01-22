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

  def power_bi_export
    to = 'petr.zaparka@hmcts.net'
    attachments['export.zip'] = File.read('export.zip')
    mail(:to => to,
         :subject => "Please see the export attached") do |format|
      format.text { render plain: 'test' }
    end
  end
end
