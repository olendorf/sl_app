# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  
  def authenticate_admin_user!
    if user_signed_in? && !current_user.can_be_admin?
      redirect_to(
        root_path
      ) && return
    end
    redirect_to new_user_session_path unless authenticate_user!
  end
end
