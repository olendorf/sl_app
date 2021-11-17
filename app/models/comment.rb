# frozen_string_literal: true

# Comments for service tickets.
class Comment < ApplicationRecord
  validates_presence_of :text
  validates_presence_of :author
  belongs_to :service_ticket
end
