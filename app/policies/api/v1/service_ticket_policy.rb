class Api::V1::ServiceTicketPolicy < ApplicationPolicy
    def show?
      @user.can_be_owner?
    end
    
    def create?
      show?
    end 
    
    def update?
      show?
    end 
    
    def index?
      show?
    end

end
