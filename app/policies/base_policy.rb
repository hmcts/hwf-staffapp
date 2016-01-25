class BasePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  module RoleMethods
    %i[staff manager admin mi].each do |role|
      define_method("#{role}?") do
        @user.send("#{role}?")
      end
    end

    def staff_or_manager?
      staff? || manager?
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @scope.all
    end

    include RoleMethods
  end

  include RoleMethods

  def same_office?
    @record.office == @user.office
  end

  def same_application_office?
    @record.application.office == @user.office
  end
end
