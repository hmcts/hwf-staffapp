class ManagerSetup
  def initialize(user)
    @user = user
  end

  def setup_office?
    @user.manager? && (first_time_login? || office_not_setup?)
  end

  def setup_profile?
    @user.manager? && first_time_login?
  end

  private

  def first_time_login?
    @user.sign_in_count == 1
  end

  def office_not_setup?
    @user.office.jurisdictions.empty?
  end
end
