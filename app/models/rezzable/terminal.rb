class Rezzable::Terminal < ApplicationRecord
  acts_as :rezzable, class_name: 'AbstractWebObject'
end
