class Analyzable::Session < ApplicationRecord
  belongs_to :sessionable, polymorphic: true
end
