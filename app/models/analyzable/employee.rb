class Analyzable::Employee < ApplicationRecord
  belongs_to :user
  has_many :work_sessions, class_name: 'Analyzable::WorkSession'
end
