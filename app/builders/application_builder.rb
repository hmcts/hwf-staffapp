class ApplicationBuilder

  attr_reader :application, :reference

  def initialize(current_user)
    @user = current_user
  end

  def build
    Application.new(
      office_id: @user.office_id,
      user_id: @user.id,
      applicant: build_applicant,
      detail: build_details
    )
  end

  private

  def build_applicant
    Applicant.new
  end

  def build_details
    Detail.new(jurisdiction_id: @user.jurisdiction_id)
  end
end
