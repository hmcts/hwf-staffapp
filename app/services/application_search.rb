class ApplicationSearch

  attr_reader :error_message

  def initialize(reference, current_user)
    @reference = reference
    @current_user = current_user
  end

  def for_hwf
    return unless @reference.present?
    @reference.upcase!
    return false if application_exists_and_user_can_access
    return false if application_exists_and_user_cannot_access

    if online_application_exists
      @online_application
    else
      @error_message = I18n.t(:not_found, scope: scope)
      false
    end
  end

  private

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

  def user_can_access
    Pundit.policy(@current_user, @application).show?
  end

  def online_application_exists
    @online_application ||= OnlineApplication.find_by(reference: @reference.upcase)
  end

  def scope
    'activemodel.errors.models.forms/search.attributes.reference'
  end

  def application_office
    @application.office.name
  end
end
