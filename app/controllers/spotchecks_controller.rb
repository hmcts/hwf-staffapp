class SpotchecksController < ApplicationController
  before_action :authenticate_user!
  before_action :render_not_found, unless: :spotcheck_enabled?

  def show
    @application = spotcheck.application
  end

  private

  def spotcheck
    @spotcheck ||= Spotcheck.find(params[:id])
  end

  def render_not_found
    render nothing: true, status: 404
  end
end
