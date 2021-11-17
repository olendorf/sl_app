# frozen_string_literal: true

# Keep track of user requests, bug reports etc.
class ServiceTicket < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :client_key

  enum status: { open: 1, closed: 0 }

  belongs_to :user

  has_many :comments, dependent: :destroy

  accepts_nested_attributes_for :comments

  def close!
    update(status: 'closed')
  end
end
