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

  # has_many :transactions, class_name: 'Analyzable::Transaction',
  #                         dependent: :nullify,
  #                         foreign_key: :web_object_id,
  #                         before_add: :handle_attributes,
  #                         after_add: :handle_splits
  # accepts_nested_attributes_for :transactions

  has_many :splits, dependent: :destroy, as: :splittable
  accepts_nested_attributes_for :splits, allow_destroy: true

  after_initialize :set_pinged_at
  after_initialize :set_api_key

  # def server
  #   Rezzable::Server.find server_id
  # end

  def response_data
    { api_key: api_key }
  end

  def split_percent
    splits.inject(0) { |sum, split| sum + split.percent } + user.split_percent
  end

  def active?
    Time.now - pinged_at <= Settings.default.web_object.inactive_limit.minutes
  end

  # def splittable_key
  #   object_key
  # end

  # def splittable_name
  #   object_name
  # end

  # def transaction_category
  #   return 'other' unless actable

  #   actable.transaction_category
  # end

  # def transaction_description(transaction)
  #   return nil unless actable

  #   actable.transaction_description(transaction)
  # end

  # private

  # def source_type
  #   return 'Web object' if actable.nil?

  #   actable.model_name.route_key.singularize.split('_')[1..].join('_').humanize
  # end

  # def handle_attributes(transaction)
  #   assign_user_to_transaction(transaction)
  #   transaction.description = transaction_description(transaction)
  #   transaction.category = transaction_category
  #   transaction.source_key = object_key
  #   transaction.source_name = object_name
  #   transaction.source_type = source_type
  #   transaction.save
  # end

  # def assign_user_to_transaction(transaction)
  #   user.transactions << transaction
  # end

  # def handle_splits(transaction)
  #   splits.each do |share|
  #     user.handle_split(transaction, share)
  #   end
  #   server&.splits&.each do |share|
  #     user.handle_split(transaction, share)
  #   end
  # end

  def set_pinged_at
    self.pinged_at = Time.now
  end

  def set_api_key
    self.api_key ||= SecureRandom.uuid
  end
end
