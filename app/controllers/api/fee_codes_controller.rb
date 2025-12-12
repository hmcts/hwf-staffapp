# frozen_string_literal: true

module Api
  class FeeCodesController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }
    skip_after_action :verify_authorized

    def index
      fee_codes = FeeCodesLoaderService.load_fees
      render json: fee_codes, status: :ok
    rescue FeeCodesLoaderService::FeeCodesLoadError => e
      render json: { error: "Failed to load fee codes: #{e.message}" }, status: :service_unavailable
    rescue StandardError
      render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
    end
  end
end
