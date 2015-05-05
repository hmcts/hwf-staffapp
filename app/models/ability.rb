class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    else
      can :read, Office
      can :new, DwpCheck
      can :lookup, DwpCheck
      can :show, DwpCheck
      can :create, R2Calculator
      can :create, Feedback
    end
  end
end
