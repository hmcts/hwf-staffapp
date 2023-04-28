class NotifyMailer < GovukNotifyRails::Mailer

  def submission_confirmation_online(application, locale)
    @application = application
    set_template(template(locale, :completed_application_online))

    set_personalisation(application_reference_code: application.reference)

    mail(to: application.email_address)
  end

  def submission_confirmation_paper(application, locale)
    @application = application
    set_template(template(locale, :completed_application_paper))

    set_personalisation(application_reference_code: application.reference)

    mail(to: application.email_address)
  end

  def submission_confirmation_refund(application, locale)
    @application = application
    set_template(template(locale, :completed_application_refund))

    set_personalisation(application_reference_code: application.reference)

    mail(to: application.email_address)
  end

  def password_reset(user, reset_link)
    set_template(ENV.fetch('NOTIFY_PASSWORD_RESET_TEMPLATE_ID', nil))
    set_personalisation(
      name: user.name,
      password_link: reset_link
    )
    mail(to: user.email)
  end

  private

  def template(locale, method_name)
    GOVUK_NOTIFY_TEMPLATES.dig(language(locale), method_name)
  end

  def form_name_or_case_number
    number = @application.form_name.presence || @application.case_number
    # this looks like empty string but it's not
    number.presence ? number : ' '
  end

  def language(locale)
    locale == 'cy' ? :welsh : :english
  end
end
