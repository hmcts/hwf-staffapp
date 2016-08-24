class OnlineApplicationsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  def edit
    authorize online_application
    @form = Forms::OnlineApplication.new(online_application)
    @form.enable_default_jurisdiction(current_user)
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
    build_sections
  end

  def complete
    authorize online_application

    application = ApplicationBuilder.new(current_user).build_from(online_application)
    process_application(application)

    redirect_to application_confirmation_path(application)
  end

  private

  def process_application(application)
    SavingsPassFailService.new(application.saving).calculate!
    ApplicationCalculation.new(application).run
    ResolverService.new(application, current_user).complete
  end

  def online_application
    @online_application ||= OnlineApplication.find(params[:id])
  end

  def build_sections
    @applicant = Views::Overview::Applicant.new(online_application)
    @application_view = Views::Overview::Application.new(online_application)
    @details = Views::Overview::Details.new(online_application)
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
