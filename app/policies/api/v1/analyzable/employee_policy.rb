class Api::V1::Analyzable::EmployeePolicy < ApplicationPolicy        
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
  
  def pay?
    create?
  end
  
  def pay_all?
    create?
  end

end
