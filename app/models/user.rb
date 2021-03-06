# frozen_string_literal: true

# Deivse based user class.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  validate :password_complexity

  # validate :account_level_not_zero, on: :update, if: :will_save_change_to_account_level?

  devise  :database_authenticatable,
          :registerable,
          :rememberable,
          :trackable,
          :timeoutable,
          :validatable

  before_update :handle_account_payment, if: :account_payment
  before_update :adjust_expiration_date, if: :will_save_change_to_account_level?
  after_create :add_time, if: :added_time

  validates_numericality_of :account_level, greater_than_or_equal_to: 0

  attr_accessor :account_payment, :admin_update, :added_time

  has_paper_trail

  enum role: %i[user prime admin owner]

  has_many :web_objects, class_name: 'AbstractWebObject', dependent: :destroy
  has_many :transactions, dependent: :destroy,
                          class_name: 'Analyzable::Transaction',
                          before_add: :update_balance,
                          after_add: :handle_splits
  has_many :splits, dependent: :destroy, as: :splittable
  accepts_nested_attributes_for :splits, allow_destroy: true
  has_many :inventories, class_name: 'Analyzable::Inventory'
  has_many :visits, class_name: 'Analyzable::Visit', dependent: :destroy
  has_many :sessions, class_name: 'Analyzable::Session', dependent: :destroy
  has_many :products, class_name: 'Analyzable::Product', dependent: :destroy
  has_many :product_links, class_name: 'Analyzable::ProductLink',
                           dependent: :destroy

  # THese two methods need to be overridden to deal with Devise's need for emails.
  def email_required?
    false
  end

  def email_changed?
    false
  end

  #############

  def servers
    Rezzable::Server.where(user_id: id)
  end

  def terminals
    Rezzable::Terminal.where(user_id: id)
  end

  def donation_boxes
    Rezzable::DonationBox.where(user_id: id)
  end

  def traffic_cops
    Rezzable::TrafficCop.where(user_id: id)
  end

  def donations
    ids = donation_boxes.collect(&:id)
    transactions.where(transactable_id: ids)
  end

  def tip_jars
    Rezzable::TipJar.where(user_id: id)
  end

  def tips
    transactions.where(transactable_type: 'Rezzable::TipJar')
  end

  def vendors
    Rezzable::Vendor.where(user_id: id)
  end

  def sales
    transactions.where(transactable_type: 'Rezzable::Vendor')
  end

  # def splittable_key
  #   avatar_key
  # end

  # def splittable_name
  #   avatar_name
  # end

  def time_left
    expiration_date.nil? ? 0 : Time.diff(expiration_date, Time.now)
  end

  def will_save_change_to_email?
    false
  end

  def password_complexity
    if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/
      return
    end

    errors.add :password,
               'Complexity requirement not met. Please use: 1 uppercase, ' +
               '1 lowercase, 1 digit and 1 special character'
  end

  # Creates methods to test of a user is allowed to act as a role.
  # Given ROLES = [:user, :prime, :admin, :owner], will create the methods
  # #can_be_guest?, #can_be_user?, #can_be_admin? and #can_be_owner?.
  #
  # The methods return true if the user's role is equal to or less than the
  # rank of the can_be method. So if a user is an admin, #can_be_user? or
  # #can_be_admin? would return true, but
  # can_be_owner? would return false.
  #
  User.roles.each do |role_name, value|
    define_method("can_be_#{role_name}?") do
      value <= self.class.roles[role]
    end
  end

  def balance
    return 0 if transactions.size.zero?

    transactions.last.balance
  end

  def active?
    return true if can_be_owner?
    return false if account_level < 1

    expiration_date >= Time.now
  end

  def adjust_expiration_date
    return if will_save_change_to_expiration_date?
    update_column(:expiration_date, Time.now) and return if account_level.zero?

    update_column(:expiration_date,
                  Time.now + (expiration_date - Time.now) *
                  (account_level_was.to_f / account_level))
  end

  def add_time
    self.expiration_date = Time.now unless expiration_date
    self.expiration_date += 1.month.to_i * added_time
    save
  end

  def split_percent
    splits.inject(0) { |sum, split| sum + split.percent }
  end

  def check_object_weight(new_object_weight)
    web_objects_weight + new_object_weight <=
      account_level * Settings.default.account.weight_limit
  end

  def handle_account_payment
    update_column(:account_level, 1) if account_level.zero?
    added_time = account_payment.to_f / (
                        account_level * Settings.default.account.monthly_cost)
    self.expiration_date = Time.now if
      expiration_date.nil? || expiration_date < Time.now
    self.expiration_date = expiration_date + (1.month.to_i * added_time)
  end

  def handle_split(transaction, share)
    server = servers.sample
    return unless server

    amount = (share.percent / 100.0 * transaction.amount).round
    ServerSlRequest.send_money(server,
                               share.target_name,
                               amount)
    add_transaction_to_user(transaction, amount, share)
    target = User.find_by_avatar_key(share.target_key)
    add_transaction_to_target(target, amount) if target
  end

  private

  def add_transaction_to_user(transaction, amount, share)
    transactions << Analyzable::Transaction.new(
      description: "Split from transaction #{transaction.id}",
      amount: amount * -1,
      source_type: 'system',
      category: 'share',
      target_name: share.target_name,
      target_key: share.target_key,
      transaction_id: transaction.id
    )
  end

  def add_transaction_to_target(target, amount)
    balance = target.balance + amount
    Analyzable::Transaction.new(
      user_id: target.id,
      description: "Split from transaction with #{avatar_name}",
      amount: amount,
      source_type: 'system',
      category: 'share',
      target_name: avatar_name,
      target_key: avatar_key,
      balance: balance
    ).save
  end

  def handle_splits(transaction)
    return if transaction.amount <= 0

    splits.each do |share|
      handle_split(transaction, share)
    end
  end

  # Updates the user's balance that results when the transaction is added.
  def update_balance(transaction)
    if transactions.size.zero?
      transaction.balance = transaction.amount
      transaction.previous_balance = 0
    else
      transaction.previous_balance = transactions.last.balance
      transaction.balance = transactions.last.balance + transaction.amount
    end
  end
end
