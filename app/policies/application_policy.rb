class ApplicationPolicy
  attr_reader :user, :application

  def initialize(user, application)
    @user = user
    @application = application
  end

  def index?
    true
  end

  def show?
    true
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
