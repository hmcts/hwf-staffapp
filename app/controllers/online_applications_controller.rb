class OnlineApplicationsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  def edit
    authorize online_application
    @form = Forms::OnlineApplication.new(online_application)
    assign_jurisdictions
  end

  def update
    authorize online_application
    @form = Forms::OnlineApplication.new(online_application)
    @form.update_attributes(update_params)
    flash[:notice] = 'Application has been saved.' if @form.save

    assign_jurisdictions
    render :edit
  end

  def show
    authorize online_application
    @overview = Views::ApplicationOverview.new(online_application)
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

  def assign_jurisdictions
    @jurisdictions ||= current_user.office.jurisdictions
  end
end
