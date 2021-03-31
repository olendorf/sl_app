class AsyncPolicy < Struct.new(:user, :async)
  def initialize(user, record)
    @user = user
    @policy = :async
  end
  
  def index?
    @user.active?
  end
  # class Scope < Scope
  #   def resolve
  #     scope.all
  #   end
  # end
end
