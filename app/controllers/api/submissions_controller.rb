module Api
  class SubmissionsController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :authenticate

    def create
      online_submission = OnlineApplicationBuilder.new(public_app_params).build
      if online_submission.save
        render(json: { result: true, message: online_submission.reference }.to_json)
      else
        render(json: { result: false, message: 'Could not save online_submission' }.to_json)
      end
    end

    private

    # rubocop:disable MethodLength
    def public_app_params
      params.require(:jwt).permit(
        :married,
        :threshold_exceeded,
        :benefits,
        :children,
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
        :post_contact
      )
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        token == Settings.submission.token
      end
    end
  end
end
