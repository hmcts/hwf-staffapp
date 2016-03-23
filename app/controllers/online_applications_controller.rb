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

    if @form.save
      redirect_to(action: :show)
    else
      assign_jurisdictions
      render :edit
    end
  end

  def show
    authorize online_application
    @overview = Views::ApplicationOverview.new(online_application)
  end

  def complete
    authorize online_application

    application = ApplicationBuilder.new(current_user).build_from(online_application)
    application.save

    ApplicationCalculation.new(application).run
    ResolverService.new(application, current_user).complete

    redirect_to application_confirmation_path(application)
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
