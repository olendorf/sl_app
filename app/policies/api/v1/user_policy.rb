class Api::V1::UserPolicy < ApplicationPolicy
  def create?
    true
  end
  
  def show?
    @user.can_be_owner?
  end
  
  def update?
    show?
  end 
  
  def destroy?
    show?
  end 
end
