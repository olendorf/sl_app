class Api::V1::Rezzable::TerminalPolicy < Api::V1::OwnerObjectPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
