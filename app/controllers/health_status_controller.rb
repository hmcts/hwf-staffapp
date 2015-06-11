class HealthStatusController < ApplicationController
  def ping
    render json: Deployment.info
  end
end
