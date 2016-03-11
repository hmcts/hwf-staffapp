class OnlineApplicationsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  def edit
    authorize online_application
    @form = Forms::OnlineApplication.new(online_application)
  end

  private

  def online_application
    @online_application ||= OnlineApplication.find(params[:id])
  end

  def redirect_to_homepage
    redirect_to(root_path)
  end
end
