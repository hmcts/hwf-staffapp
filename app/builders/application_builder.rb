class ApplicationBuilder

  attr_reader :application, :reference

  def initialize(current_user)
    @user = current_user
  end

  def create_application
    @application = Application.create(jurisdiction_id: @user.jurisdiction_id,
                                      office_id: @user.office_id,
                                      user_id: @user.id)
  end

  def create_reference
    @reference = Reference.create(application_id: @application.id)
  end
end
