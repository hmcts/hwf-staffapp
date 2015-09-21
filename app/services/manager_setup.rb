class ManagerSetup
  def initialize(user)
    @user = user
  end

  def setup_office?
    if @user.manager?
      if @user.sign_in_count == 1
        true
      else
        @user.office.jurisdictions.empty?
      end
    else
      false
    end
  end
end
