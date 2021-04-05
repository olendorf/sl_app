class Analyzable::Visit < ApplicationRecord
  belongs_to :traffic_cop, class_name: 'Rezzable::TrafficCop', 
                           foreign_key: :web_object_id
                             
  has_many :detections, class_name: 'Analyzable::Detection', 
                        dependent: :destroy
end
