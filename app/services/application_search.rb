class ApplicationSearch
  include Rails.application.routes.url_helpers
  attr_reader :error_message

  def initialize(reference, current_user)
    @reference = reference
    @current_user = current_user
  end

  def online
    return if !prepare_reference! || application_exists_and_user_can_access ||
              application_exists_and_user_cannot_access || online_application_income_invalid?

    if online_application_exists
      edit_online_application_path(@online_application)
    else
      set_error_and_return_nil(:not_found)
    end
  end

  def completed
    if application_exists && application_completed
      if user_can_access
        CompletedApplicationRedirect.new(@application).path
      else
        set_error_and_return_nil(:processed_by, office_name: application_office)
      end
    else
      set_error_and_return_nil(:not_found)
    end
  end

  private

  def prepare_reference!
    if @reference.present?
      reference = @reference.upcase
      reference.gsub!('HWF', '')
      reference.gsub!(/[- ]/, '')
      @reference = "HWF-#{reference.scan(/.{1,3}/).join('-')}"
    end
  end

  def application_exists_and_user_can_access
    if application_exists && user_can_access
      redirect_data = CompletedApplicationRedirect.new(@application)
      @error_message = I18n.t(:processed_html, scope: scope, application_path: redirect_data.path)
    end
  end

  def application_exists_and_user_cannot_access
    if application_exists && !user_can_access
      @error_message = I18n.t(:processed_by, scope: scope, office_name: application_office)
    end
  end

  def application_exists
    @application ||= Application.find_by(reference: @reference.upcase)
  end

  def application_completed
    !@application.created?
  end

  def user_can_access
    Pundit.policy(@current_user, @application).show?
  end

  def online_application_exists
    @online_application ||= OnlineApplication.find_by(reference: @reference.upcase)
  end

  def online_application_income_invalid?
    if online_application_exists && income_required_but_missing
      @error_message = I18n.t(:income_error, scope: scope)
    end
  end

  def income_required_but_missing
    online_application_income_required? && online_application_income_missing?
  end

  def online_application_income_required?
    @online_application.benefits.eql?(false)
  end

  def online_application_income_missing?
    [
      @online_application.income,
      @online_application.income_min_threshold_exceeded,
      @online_application.income_max_threshold_exceeded
    ].all?(&:nil?)
  end

  def scope
    'activemodel.errors.models.forms/search.attributes.reference'
  end

  def application_office
    @application.office.name
  end

  def set_error_and_return_nil(i18n_key, i18n_params = {})
    @error_message = I18n.t(i18n_key, { scope: scope }.merge(i18n_params))
    nil
  end
end
