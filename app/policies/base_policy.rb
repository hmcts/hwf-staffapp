class BasePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
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

    %i[staff manager admin].each do |role|
      define_method("#{role}?") do
        @user.send("#{role}?")
      end
    end
  end

  %i[staff manager admin].each do |role|
    define_method("#{role}?") do
      @user.send("#{role}?")
    end
  end
end
