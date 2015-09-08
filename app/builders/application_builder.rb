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
    @reference = Reference.create(application_id: @application.id,
                                  reference: format_reference)
  end

  private

  def format_reference
    entity_code = @user.office.entity_code
    current_year = Time.zone.now.strftime('%y')
    code_and_year = "#{entity_code}-#{current_year}"
    counter = Reference.where("reference like ?", "#{code_and_year}-%").count + 1
    "#{code_and_year}-#{counter}"
  end
end
