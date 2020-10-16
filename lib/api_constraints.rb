# frozen_string_literal: true

# Helper for versioning the api routes
class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?(
      "application/vnd.example.v#{@version}"
    )
  end
end