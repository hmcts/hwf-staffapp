class ManagerSetup
  SESSION_KEY = :manager_setup_in_progress

  def initialize(user, session)
    @user = user
    @session = session
  end

  def setup_office?
    @user.manager? && first_time_login?
  end

  def setup_profile?
    @user.manager? && first_time_login?
  end

  def start!
    @session[SESSION_KEY] = true
  end

  def in_progress?
    @session.key?(SESSION_KEY)
  end

  def finish!
    @session.delete(SESSION_KEY)
  end

  private

  def first_time_login?
    @user.sign_in_count == 1
  end
end
