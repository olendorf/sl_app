# frozen_string_literal: true

# Base class for objects rezzable in SL
class AbstractWebObject < ApplicationRecord
  validates_presence_of :object_name
  validates_presence_of :object_key
  validates_presence_of :region
  validates_presence_of :position
  validates_presence_of :url

  actable

  belongs_to :user, optional: true

  belongs_to :server, class_name: 'Rezzable::Server', optional: true, inverse_of: :clients

  has_many :splits, dependent: :destroy, as: :splittable
  accepts_nested_attributes_for :splits, allow_destroy: true

  after_initialize :set_pinged_at
  after_initialize :set_api_key

  # def server
  #   Rezzable::Server.find server_id
  # end

  def increment_caches
    return unless user

    user.web_objects_count += 1
    user.web_objects_weight += actable.class::OBJECT_WEIGHT
    user.save
  end

  def decrement_caches
    return unless user

    user.web_objects_count = user.web_objects_count - 1
    user.web_objects_weight = user.web_objects_weight - actable.class::OBJECT_WEIGHT
    user.save
  end

  def object_weight
    actable.class::OBJECT_WEIGHT
  end

  def response_data
    { api_key: api_key }
  end

  def split_percent
    splits.inject(0) { |sum, split| sum + split.percent } + user.split_percent
  end

  def active?
    Time.now - pinged_at <= Settings.default.web_object.inactive_limit.minutes
  end

  def set_pinged_at
    self.pinged_at = Time.now
  end

  def set_api_key
    self.api_key ||= SecureRandom.uuid
  end
end
