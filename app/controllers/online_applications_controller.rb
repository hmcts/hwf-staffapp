class OnlineApplicationsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  def edit
    authorize online_application
    @form = Forms::OnlineApplication.new(online_application)
  end

  def update
    authorize online_application
    @form = Forms::OnlineApplication.new(online_application)
    @form.update_attributes(update_params)
    @form.valid?
    render :edit
  end

  private

  def online_application
    @online_application ||= OnlineApplication.find(params[:id])
  end

  def redirect_to_homepage
    redirect_to(root_path)
  end

  def update_params
    params.require(:online_application).permit(*Forms::OnlineApplication.permitted_attributes.keys)
  end
end
