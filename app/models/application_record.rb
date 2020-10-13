# frozen_string_literal: true

# default class in rails.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
