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

  def file_report_ready(user, storage_id)
    set_template(ENV.fetch('NOTIFY_RAW_DATA_READY_TEMPLATE_ID', nil))

    set_personalisation(
      name: user.name,
      link_to_download_page: link_for_file_download(user.id, storage_id)
    )
    mail(to: user.email)
  end

  def confirmation_instructions(user, token)
    set_template(ENV.fetch('NOTIFY_CONFIRMATION_EMAIL_TEMPLATE_ID', nil))

    set_personalisation(
      name: user.name,
      confirmation_link: link_for_user_confirmation(token)
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

  def url_host
    @url_host ||= ENV.fetch('URL_HELPER_DOMAIN', nil)
  end

  def link_for_file_download(user_id, storage_id)
    if url_host
      user_export_file_url(user_id, storage_id, host: url_host)
    else
      user_export_file_url(user_id, storage_id)
    end
  end

  def link_for_user_confirmation(token)
    if url_host
      user_confirmation_url(confirmation_token: token, host: url_host)
    else
      user_confirmation_url(confirmation_token: token)
    end
  end

end
