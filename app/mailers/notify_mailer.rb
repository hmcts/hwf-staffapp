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

  def dwp_is_down_notifier
    set_template(ENV.fetch('NOTIFY_DWP_DOWN_TEMPLATE_ID', nil))
    set_personalisation(
      environment: ENV.fetch('ENV', 'test')
    )
    mail(to: Settings.mail.dwp_notification_alert)
  end

  def user_invite(user)
    set_template(ENV.fetch('NOTIFY_USER_INVITE_TEMPLATE_ID', nil))
    set_personalisation(
      name: user.name,
      invite_url: accept_user_invitation_url(invitation_token: user.raw_invitation_token)
    )
    mail(to: user.email)
  end

  def raw_data_extract_ready(user, storage_id)
    set_template(ENV.fetch('NOTIFY_RAW_DATA_READY_TEMPLATE_ID', nil))
    set_personalisation(
      name: user.name,
      link_to_download_page: user_file_download_url(user.id, storage_id)
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
