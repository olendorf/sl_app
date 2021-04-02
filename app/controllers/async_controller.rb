# frozen_string_literal: true

class AsyncController < ApplicationController
  include Pundit

  after_action :verify_authorized

  # def pundit_user
  #   current_user
  # end
end
