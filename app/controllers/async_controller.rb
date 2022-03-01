# frozen_string_literal: true

# Parent class for controllers handling asynchronous requests.
class AsyncController < ApplicationController
  include Pundit::Authorization

  after_action :verify_authorized

  # def pundit_user
  #   current_user
  # end
end
