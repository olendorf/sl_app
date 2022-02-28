# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      class TimeCopPolicy < Api::V1::RezzablePolicy
        def pay_all?
          show?
        end 
        
        def pay?
          show?
        end
      end
    end
  end
end
