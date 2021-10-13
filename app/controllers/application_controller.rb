# frozen_string_literal: true

# Base controller class
class ApplicationController < ActionController::Base
  include Pundit

  before_action :set_paper_trail_whodunnit
  
  def after_sign_out_path_for(resource_or_scope)
    '/'
  end

  def authenticate_admin_user!
    if user_signed_in? && !current_user.can_be_admin?
      redirect_to(
        my_dashboard_path
      ) && return
    end

    redirect_to new_user_session_path unless authenticate_user!
  end
end
