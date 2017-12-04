class ApplicationFormSave
  include Rails.application.routes.url_helpers
  attr_reader :application, :form_params, :redirect_url, :form

  def initialize(application, form_params)
    @application = application
    @form_params = form_params
    @success = false
  end

  def details
    @form = Forms::Application::Detail.new(application.detail)
    update_form_attributes_and_save

    if @form.errors.blank? && continue_with_discretion_applied?
      @redirect_url = application_savings_investments_path(application)
    elsif @form.errors.blank? && !continue_with_discretion_applied?
      @redirect_url = application_summary_path(application)
      application.update(outcome: 'none')
    end
    @form
  end

  def success?
    @success
  end

  private

  def update_form_attributes_and_save
    @form.update_attributes(form_params)
    @success = @form.save
  end

  def continue_with_discretion_applied?
    @form.discretion_applied != false
  end
end