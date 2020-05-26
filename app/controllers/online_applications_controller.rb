class OnlineApplicationsController < ApplicationController
  before_action :authorize_online_application, except: :create
  before_action :check_completed_redirect
  before_action only: [:edit, :show] do
    track_online_application(online_application)
  end
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
      decide_next_step
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

    redirect_to application_confirmation_path(application, 'digital')
  end

  def approve
    @form = Forms::FeeApproval.new(online_application)
  end

  def approve_save
    @form = Forms::FeeApproval.new(online_application)
    @form.update_attributes(update_approve_params)

    if @form.save
      redirect_to action: :show
    else
      render :approve
    end
  end

  private

  def process_application(application)
    SavingsPassFailService.new(application.saving).calculate!
    ApplicationCalculation.new(application).run
    benefit_override(application) if online_application.benefits_override
    ResolverService.new(application, current_user).complete
  end

  def benefit_override(application)
    @benefit_override = BenefitOverride.find_or_initialize_by(application: application)
    return unless authorize @benefit_override, :create?
    @benefit_override.update(correct: true, completed_by: current_user)
    application.update(outcome: 'full')
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

  def decide_next_step
    if @form.fee < Settings.fee_approval_threshold
      reset_fee_manager_approval_fields
      if display_paper_evidence_page?
        redirect_to benefits_online_application_path(online_application)
      else
        redirect_to action: :show
      end
    else
      redirect_to action: :approve
    end
  end

  def display_paper_evidence_page?
    online_application.benefits && DwpMonitor.new.state == 'offline'
  end

  def reset_fee_manager_approval_fields
    online_application.update(fee_manager_firstname: nil, fee_manager_lastname: nil)
  end

  def online_application
    @online_application ||= OnlineApplication.find(params[:id])
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
