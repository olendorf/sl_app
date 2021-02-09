# frozen_string_literal: true

# Base class for objects rezzable in SL
class AbstractWebObject < ApplicationRecord
  validates_presence_of :object_name
  validates_presence_of :object_key
  validates_presence_of :region
  validates_presence_of :position
  validates_presence_of :url

  actable

  belongs_to :user

  has_many :splits, dependent: :destroy, as: :splittable

  after_initialize :set_pinged_at
  after_initialize :set_api_key

  def active?
    Time.now - pinged_at <= Settings.default.web_object.inactive_limit
  end

  private

  def set_pinged_at
    self.pinged_at ||= Time.now
  end

  def set_api_key
    self.api_key ||= SecureRandom.uuid
  end
end
