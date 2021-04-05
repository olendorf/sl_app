class ListableAvatar < ApplicationRecord
  belongs_to :listable, polymorphic: true
end
