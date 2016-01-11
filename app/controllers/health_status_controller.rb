class HealthStatusController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def ping
    render json: Deployment.info
  end

  def raise_exception
    raise "THIS IS A TEST EXCEPTION RAISED ON PURPOSE"
  end

  def healthcheck
    health = HealthStatus.current_status
    render json: health, status: health[:ok].equal?(true) ? 200 : 500
  end
end
