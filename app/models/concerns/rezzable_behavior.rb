# frozen_string_literal: true

# Shared methods for rezzable models
module RezzableBehavior
  extend ActiveSupport::Concern

  included do
    after_create :increment_caches
    after_destroy :decrement_caches
  end
end
