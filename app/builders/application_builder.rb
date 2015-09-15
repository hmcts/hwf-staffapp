class ApplicationBuilder

  attr_reader :application, :reference

  def initialize(current_user)
    @user = current_user
  end

  def create
    Application.create(
      jurisdiction_id: @user.jurisdiction_id,
      office_id: @user.office_id,
      user_id: @user.id,
      reference: generate_reference
    )
  end

  private

  def generate_reference
    entity_code = @user.office.entity_code
    current_year = Time.zone.now.strftime('%y')
    code_and_year = "#{entity_code}-#{current_year}"
    counter = Application.where('reference like ?', "#{code_and_year}-%").count + 1

    "#{code_and_year}-#{counter}"
  end
end
