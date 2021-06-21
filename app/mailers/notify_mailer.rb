class NotifyMailer < GovukNotifyRails::Mailer

  def submission_confirmation(application)
    set_template(template(:english, :completed_application))

    set_personalisation(
      application_reference_code: application.reference,
      enter_details_here: 'Forn name?',
      application_submitted_date: application.date_received,
      applicant_name: application.full_name
    )

    mail(to: application.email_address)
  end

  def submission_confirmation_refund(application)
    set_template(template(:english, :completed_application_refund))

    set_personalisation(
      application_reference_code: application.reference,
      application_submitted_date: application.date_received,
      applicant_name: application.full_name
    )

    mail(to: application.email_address)
  end

  private

  def template(language, method_name)
    GOVUK_NOTIFY_TEMPLATES.dig(language || :english, method_name)
  end
end
