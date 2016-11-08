class OnlineApplicationsController < ApplicationController
  before_action :authorize_online_application, except: :create
  before_action :check_completed_redirect
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  include SectionViewsHelper

  def edit
    @form = Forms::OnlineApplication.new(online_application)
    @form.enable_default_jurisdiction(current_user)
    assign_jurisdictions
  end

  def update
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
    build_sections
  end

  def complete
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

  def authorize_online_application
    authorize online_application
  end

  def check_completed_redirect
    set_cache_headers
    if online_application.processed?
      flash[:alert] = I18n.t('application_redirect.processed')
      redirect_to application_confirmation_path(online_application.linked_application)
    end
  end

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
