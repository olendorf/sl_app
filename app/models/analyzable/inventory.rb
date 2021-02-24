class Analyzable::Inventory < ApplicationRecord
  
  validates_presence_of :inventory_name
  validates :inventory_name, uniqueness: { scope: :server_id }
  validates_presence_of :inventory_type
  validates_presence_of :owner_perms
  validates_presence_of :next_perms
  
  belongs_to :user
  belongs_to :server, class_name: 'Rezzable::Server'
end
