class AbstractWebObject < ApplicationRecord
  validates_presence_of :object_name
  validates_presence_of :object_key
  validates_presence_of :region
  validates_presence_of :position
  validates_presence_of :url
  
  actable
  
  belongs_to :user
end
