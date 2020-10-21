class Api::V1::RezzablePolicy < ApplicationPolicy
  
  def show? 
    true
  end 
  
  def destroy?
    show?
  end
  
  def update?
    # return true if @user.can_be_owner?
    @user.is_active?
  end
  
  def create?
    @user.is_active?
  end
  
  
  
  # class Scope < Scope
  #   def resolve
  #     scope.all
  #   end
  # end
end
