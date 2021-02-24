class Api::V1::Analyzable::InventoryPolicy < ApplicationPolicy
  def create?
    @user.active?
  end 
  
  def show?
    create?
  end 
  
  def update? 
    create?
  end 
  
  def index?
    create?
  end 
  
  def destroy?
    create?
  end
end
