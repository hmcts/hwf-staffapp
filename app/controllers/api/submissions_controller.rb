module Api
  class SubmissionsController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :authenticate

    def create
      result = { result: true, message: public_app_params['jwt'] }
      render(json: result.to_json)
    end

    private

    def public_app_params
      params.permit(:jwt)
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        token == Settings.submission.token
      end
    end
  end
end
