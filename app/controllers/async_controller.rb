class AsyncController < ApplicationController
  include Pundit
  

  after_action :verify_authorized
  
  private 
    # def pundit_user
    #   current_user
    # end
end
