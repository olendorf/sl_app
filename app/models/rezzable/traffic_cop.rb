class Rezzable::TrafficCop < ApplicationRecord
  acts_as :abstract_web_object
  
  has_many :visits, class_name: 'Analyzable::Visit', 
                    dependent: :destroy, 
                    foreign_key: :web_object_id
                      
  has_many :listable_avatars, as: :listable, dependent: :destroy
  
  LISTS = [:allowed, :banned]
  
  LISTS.each do |list|
    define_method("add_to_#{list}_list") do |avatar_name, avatar_key|
      listable_avatars << ListableAvatar.new(
                                        avatar_name: avatar_name, 
                                        avatar_key: avatar_key, 
                                        list_name: list.to_s
                                      )
    end
  end
  
  enum sensor_mode: {
    sensor_mode_region: 0, 
    sensor_mode_parcel: 1, 
    sensor_mode_owned_parcels: 2
  }
  
  enum security_mode: {
    security_mode_off: 0, 
    security_mode_parcel: 1, 
    security_mode_owned_parcels: 2
  }
end
