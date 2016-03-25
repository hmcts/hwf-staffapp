class ApplicationMailer < ActionMailer::Base
  default from: Settings.mail.from
  layout 'mailer'
end
