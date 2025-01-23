class OnlineApplicationsController < ApplicationController
  before_action :authorize_online_application, except: :create
  before_action :check_completed_redirect
  before_action only: [:edit, :show] do
    track_online_application(online_application)
  end
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  include SectionViewsHelper
  include OnlineApplicationHelper

  def show
    build_sections
  end

  def edit
    @form = Forms::OnlineApplication.new(online_application)
    @form.enable_default_jurisdiction(current_user)
    assign_jurisdictions
  end

  def update
    @form = Forms::OnlineApplication.new(online_application)
    @form.update(update_params.merge('user_id' => current_user.id))

    if @form.save || @form.discretion_applied == false
      decide_next_step(@form)
    else
      assign_jurisdictions
      render :edit
    end
  end

  def complete
    application = linked_application
    if process_application(application) == false
      flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
      redirect_to_homepage
    else
      redirect_to application_confirmation_path(application, 'digital')
    end
  end

  def approve
    @form = Forms::FeeApproval.new(online_application)
  end

  def approve_save
    @form = Forms::FeeApproval.new(online_application)
    @form.update(update_approve_params)

    if @form.save
      redirect_to action: :show
    else
      render :approve
    end
  end

  private

  def process_application(application)
    ProcessApplication.new(application, online_application, current_user).process
  end

  def authorize_online_application
    authorize online_application
  end

  def online_application
    @online_application ||= OnlineApplication.find(params[:id])
  end

  def linked_application
    online_application.linked_application || ApplicationBuilder.new(current_user).build_from(online_application)
  end

  def redirect_to_homepage
    redirect_to(root_path)
  end

  def update_params
    params.require(:online_application).
      permit(*Forms::OnlineApplication.permitted_attributes.keys).to_h
  end

  def update_approve_params
    params.require(:online_application).permit(*Forms::FeeApproval.permitted_attributes.keys).to_h
  end

  def assign_jurisdictions
    @jurisdictions ||= current_user.office.jurisdictions
  end

end
