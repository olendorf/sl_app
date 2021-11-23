# frozen_string_literal: true

# Shared methods for rezzable models
module RentableBehavior
  extend ActiveSupport::Concern

  included do    
    has_many :states, as: :rentable, dependent: :destroy,
                      after_add: :set_current_state, 
                      class_name: 'Analyzable::RentalState'
  end
  
  def set_current_state(state)
    self.current_state = state.state
  end
end
