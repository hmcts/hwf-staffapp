class SpotchecksController < ApplicationController
  before_action :authenticate_user!

  def show
    @application = spotcheck.application
  end

  private

  def spotcheck
    @spotcheck ||= Spotcheck.find(params[:id])
  end
end
