class Rezzable::Server < ApplicationRecord
    acts_as :abstract_web_object
    
    has_many :clients, class_name: 'AbstractWebObject'
end
