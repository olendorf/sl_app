class AbstractWebObject < ApplicationRecord
  validates_presence_of :object_name
  validates_presence_of :object_key
  validates_presence_of :region
  validates_presence_of :position
  validates_presence_of :url
  
  actable inverse_of: 'abstract_web_object'
  
  belongs_to :user
  
  after_initialize :set_pinged_at
  
  
  private
  
  def set_pinged_at
    self.pinged_at ||= Time.now
  end
end
