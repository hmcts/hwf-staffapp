class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    elsif user.manager?
      can [:read, :create, :show], User, office_id: user.office_id
      users_can
    else
      users_can
    end
  end

private

  def users_can
    can :read, Office
    can :new, DwpCheck
    can :lookup, DwpCheck
    can :show, DwpCheck
    can :create, R2Calculator
    can :create, Feedback
  end
end
