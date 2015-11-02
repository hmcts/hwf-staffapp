class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    elsif user.manager?
      can [:manage], User do |staff_member|
        can_manage_user?(user, staff_member)
      end
      cannot [:list_deleted], User
      can [:edit, :update], Office, id: user.office_id
      users_can
    else
      users_can
      users_can_manage_their_profile
    end
  end

  def can_manage_user?(manager, staff_member)
    if staff_member.office_id != manager.office_id
      raise CanCan::AccessDenied.new(I18n.t('unauthorized.manage.wrong_office'), User, :manage)
    end

    true
  end

  private

  def users_can
    can :read, Office
    can :new, DwpCheck
    can :lookup, DwpCheck
    can :show, DwpCheck
    can :create, Feedback
  end

  def users_can_manage_their_profile
    can :show, User
    can :edit, User
    can :update, User
  end
end
