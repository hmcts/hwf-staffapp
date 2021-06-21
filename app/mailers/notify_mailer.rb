class NotifyMailer < GovukNotifyRails::Mailer

  def my_test_email
    set_template('ab017b1b-0f5a-45df-b2c5-467f97a54828')

    set_personalisation(
      application_reference_code: 'application ref code',
      enter_details_here: 'Forn name?',
      application_submitted_date: Time.zone.now,
      applicant_name: 'Jon Dean'
    )

    mail(to: 'petr.zaparka@hmcts.net')
  end
end
