class PingController < ApplicationController
  def index
    render json: Deployment.info
  end
end
