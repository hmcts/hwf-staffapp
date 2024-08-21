module Api
  class SubmissionsController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :authenticate

    def create
      online_submission = OnlineApplicationBuilder.new(public_app_params).build

      if online_submission.save
        MailService.new(online_submission, public_app_locale).send_public_confirmation
        render(json: { result: true, message: online_submission.reference })
      else
        render(json: { result: false, message: 'Could not save online_submission' })
      end
    end

    private

    # rubocop:disable Metrics/MethodLength
    def public_app_params
      params.require(:online_application).permit(
        :married,
        :min_threshold_exceeded,
        :max_threshold_exceeded,
        :over_66,
        :amount,
        :benefits,
        :children,
        :income_min_threshold_exceeded,
        :income_max_threshold_exceeded,
        :income,
        :refund,
        :date_fee_paid,
        :probate,
        :deceased_name,
        :date_of_death,
        :case_number,
        :form_name,
        :ni_number,
        :ho_number,
        :partner_ni_number,
        :date_of_birth,
        :title,
        :first_name,
        :last_name,
        :address,
        :postcode,
        :email_contact,
        :email_address,
        :phone_contact,
        :phone,
        :post_contact,
        :feedback_opt_in,
        :applying_method,
        :partner_date_of_birth,
        :partner_first_name,
        :partner_last_name,
        :calculation_scheme,
        :applying_on_behalf,
        :legal_representative,
        :legal_representative_first_name,
        :legal_representative_last_name,
        :legal_representative_email,
        :legal_representative_organisation_name,
        :legal_representative_feedback_opt_in,
        :legal_representative_street,
        :legal_representative_postcode,
        :legal_representative_town,
        :legal_representative_address,
        :legal_representative_position,
        :over_16,
        :statement_signed_by,
        :income_period,
        children_age_band: {},
        income_kind: { applicant: [], partner: [] }
      ).to_h
    end

    def public_app_locale
      params.require(:locale)
    end
    # rubocop:enable Metrics/MethodLength

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        token == Settings.submission.token
      end
    end
  end

end
