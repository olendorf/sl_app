class Analyzable::Detection < ApplicationRecord
  belongs_to :visit, class_name: 'Analyzable::Visit'
end
