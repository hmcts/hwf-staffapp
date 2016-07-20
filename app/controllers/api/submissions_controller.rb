module Api
  class SubmissionsController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :authenticate

    def create
      online_submission = OnlineApplicationBuilder.new(public_app_params).build
      if online_submission.save
        MailService.new(online_submission).send_public_confirmation
        render(json: { result: true, message: online_submission.reference })
      else
        render(json: { result: false, message: 'Could not save online_submission' })
      end
    end

    private

    # rubocop:disable MethodLength
    def public_app_params
      params.require(:online_application).permit(
        :married,
        :min_threshold_exceeded,
        :max_threshold_exceeded,
        :over_61,
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
        :feedback_opt_in
      )
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        token == Settings.submission.token
      end
    end
  end
end
