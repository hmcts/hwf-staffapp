class NotifyMailer < GovukNotifyRails::Mailer

  def submission_confirmation(application, locale)
    @application = application
    set_template(template(locale, :completed_application))

    set_personalisation(
      application_reference_code: application.reference,
      form_name_case_number: form_name_or_case_number,
      application_submitted_date: Time.zone.today.to_s(:db),
      applicant_name: application.full_name
    )

    mail(to: application.email_address)
  end

  def submission_confirmation_refund(application, locale)
    @application = application
    set_template(template(locale, :completed_application_refund))

    set_personalisation(
      application_reference_code: application.reference,
      application_submitted_date: Time.zone.today.to_s(:db),
      applicant_name: application.full_name,
      form_name_case_number: form_name_or_case_number
    )

    mail(to: application.email_address)
  end

  def password_reset(user, reset_link)
    set_template(ENV['NOTIFY_PASSWORD_RESET_TEMPLATE_ID'])
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
