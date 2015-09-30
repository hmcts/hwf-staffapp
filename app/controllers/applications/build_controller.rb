class Applications::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :find_application, only: [:show, :update]
  before_action :populate_jurisdictions, only: [:show, :update]

  before_action :spotcheck_show_redirect, only: :show
  before_action :spotcheck_update_redirect, only: :update

  steps :personal_information,
    :application_details,
    :savings_investments,
    :benefits,
    :benefits_result,
    :income,
    :income_result,
    :summary,
    :confirmation

  FORM_OBJECTS = %i[personal_information application_details savings_investments benefits income]

  def create
    application_builder = ApplicationBuilder.new(current_user)
    @application = application_builder.create
    redirect_to wizard_path(steps.first, application_id: @application.id)
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
    spotcheck_selection

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
    ['Forms::', status.to_s.classify].join('').constantize
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
      @application.update(form_params.merge(status))
      render_wizard @application
    else
      render_wizard
    end
  end

  def spotcheck_selection
    if next_step?(:summary)
      SpotcheckSelector.new(@application, Settings.spotcheck.expires_in_days).decide!
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

  def spotcheck_show_redirect
    redirect_if_spotcheck if step == :confirmation
  end

  def spotcheck_update_redirect
    redirect_if_spotcheck if next_step == :confirmation
  end

  def redirect_if_spotcheck
    if spotcheck_enabled? && @application.spotcheck?
      redirect_to(spotcheck_path(@application.spotcheck.id))
    end
  end
end
