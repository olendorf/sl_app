class Analyzable::WorkSession < ApplicationRecord
  belongs_to :employee, class_name: 'Analyzable::Employee'
  
end
