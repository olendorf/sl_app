# frozen_string_literal: true

module Api
  # Handles api json responses.
  module ResponseHandler
    def json_response(object, status = :ok)
      render json: object, status: status
    end
  end
end