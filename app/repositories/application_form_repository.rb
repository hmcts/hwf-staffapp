class ApplicationFormRepository
  include Rails.application.routes.url_helpers
  attr_reader :application, :form_params, :redirect_url, :form

  def initialize(application, form_params)
    @application = application
    @form_params = form_params
    @success = false
  end

  def process(form_name)
    form_class = format_form_class_name(form_name)
    @form = form_class.new(application.detail)
    update_form_attributes_and_save
    load_template_path
    @form
  end

  def success?
    @success
  end

  private

  def format_form_class_name(form_name)
    form_name = form_name.to_s.classify
    "Forms::Application::#{form_name}".constantize
  end

  def update_form_attributes_and_save
    @form.update_attributes(form_params)
    @success = @form.save
  end

  def continue_with_discretion_applied?
    @form.discretion_applied != false
  end

  def application_outcome(outcome)
    application.update(outcome: outcome)
  end

  def load_template_path
    if @form.errors.blank? && continue_with_discretion_applied?
      @redirect_url = application_savings_investments_path(application)
    elsif @form.errors.blank? && !continue_with_discretion_applied?
      @redirect_url = application_summary_path(application)
      application_outcome('none')
    end
  end

end
