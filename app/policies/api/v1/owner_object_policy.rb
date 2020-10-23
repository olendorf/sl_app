class Api::V1::OwnerObjectPolicy < Api::V1::RezzablePolicy
  
  def show?
    @user.can_be_owner?
  end 
  
  def create?
    show?
  end 
  
  def update?
    show?
  end 
  
  def destroy? 
    show?
  end 
  
  # class Scope < Scope
  #   def resolve
  #     scope.all
  #   end
  # end
end
