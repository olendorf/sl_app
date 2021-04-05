# frozen_string_literal: true

AsyncPolicy = Struct.new(:user, :async) do
  def initialize(user, _record)
    @user = user
    @policy = :async
  end

  def index?
    @user.active?
  end
end
