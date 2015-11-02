# rubocop:disable ClassLength
class Applications::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :find_application, only: [:show, :update]
  before_action :populate_jurisdictions, only: [:show, :update]

  before_action :redirect_to_process_controller, only: :show
  before_action :render_bad_request_for_process_controller_action, only: :update

  before_action :evidence_check_show_redirect, only: :show
  before_action :evidence_check_update_redirect, only: :update

  steps :personal_information,
    :application_details,
    :savings_investments,
    :benefits,
    :benefits_result,
    :income,
    :income_result,
    :summary,
    :confirmation

  PROCESS_CONTROLLER_ACTIONS = %i[personal_information application_details summary]
  FORM_OBJECTS = %i[savings_investments benefits income]

  def create
    application_builder = ApplicationBuilder.new(current_user)
    @application = application_builder.create
    redirect_to application_personal_information_path(@application)
  end

  # rubocop:disable MethodLength
  def show # rubocop:disable CyclomaticComplexity
    if FORM_OBJECTS.include?(step)
      @form = derive_class(step).new(@application)
    end

    case step
    when :benefits
      jump_to(:summary) unless @application.savings_investment_valid?
    when :benefits_result
      jump_to(:income) unless @application.benefits
    when :income
      jump_to(:summary) if @application.benefits
    end
    render_wizard
  end

  def update
    evidence_check_selection
    create_payment_if_needed

    if FORM_OBJECTS.include?(step)
      handle_form_object(params, step)
    else
      status = { status: get_status(step) }
      @application.update(application_params.merge(status))
      render_wizard @application
    end
  end

  private

  def get_status(step)
    (step == steps.last) ? 'active' : step.to_s
  end

  def derive_class(status)
    ['Applikation::Forms::', status.to_s.classify].join('').constantize
  end

  def process_params(class_name, params)
    form_params = params.require(:application).permit(class_name.permitted_attributes.keys)
    application_id_param = { application_id: params['application_id'] }
    form_params.merge!(application_id_param)
    form_params
  end

  def handle_form_object(params, step)
    class_name = derive_class(step)
    form_params = process_params(class_name, params)

    @form = class_name.new(form_params)
    if @form.valid?
      status = { status: get_status(step) }
      form_params.delete('application_id')
      form_params.delete('emergency') if form_params.key?(:emergency)
      @application.update(form_params.merge(status))
      render_wizard @application
    else
      render_wizard
    end
  end

  def evidence_check_selection
    if next_step?(:summary) && evidence_check_enabled?
      EvidenceCheckSelector.new(@application, Settings.evidence_check.expires_in_days).decide!
    end
  end

  def create_payment_if_needed
    if next_step?(:summary) && payment_enabled?
      PaymentBuilder.new(@application, Settings.payment.expires_in_days).decide!
    end
  end

  def find_application
    @application = Application.find(params[:application_id])
  end

  def application_params
    all_params = %i[status dependents income children]
    params.require(:application).permit(all_params.flatten)
  end

  def populate_jurisdictions
    @jurisdictions = current_user.office.jurisdictions
  end

  def evidence_check_show_redirect
    redirect_if_evidence_check if step == :confirmation
  end

  def evidence_check_update_redirect
    redirect_if_evidence_check if next_step == :confirmation
  end

  def redirect_if_evidence_check
    if evidence_check_enabled? && @application.evidence_check?
      redirect_to(evidence_check_path(@application.evidence_check.id))
    end
  end

  def redirect_to_process_controller
    if PROCESS_CONTROLLER_ACTIONS.include?(step)
      redirect_to(send("application_#{step}_path", @application))
    end
  end

  def render_bad_request_for_process_controller_action
    if PROCESS_CONTROLLER_ACTIONS.include?(step)
      render nothing: true, status: 400
    end
  end
end
