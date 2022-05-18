class Api::V1::Rezzable::WebObjectPolicy < ApplicationPolicy
  def show?
    true
  end
  
  def create?
    true
  end  
  
  def update?
    true
  end
  
  def index?
    true
  end
  
  def destroy?
    true
  end
  

end
