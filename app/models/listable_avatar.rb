# frozen_string_literal: true

class ListableAvatar < ApplicationRecord
  belongs_to :listable, polymorphic: true
end
