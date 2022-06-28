# frozen_string_literal: true

# Shared methods for models that are able to accept money
module TransactableBehavior
  extend ActiveSupport::Concern

  included do
    has_many :transactions, as: :transactable,
                            class_name: 'Analyzable::Transaction',
                            dependent: :nullify,
                            before_add: :process_transaction,
                            after_add: :handle_splits
    accepts_nested_attributes_for :transactions

    has_many :splits, dependent: :destroy, as: :splittable
    accepts_nested_attributes_for :splits, allow_destroy: true
  end

  def process_transaction(transaction)
    transaction.user_id = user.id
    transaction.description = transaction_description(transaction)
    transaction.category = transaction_category
    transaction.source_key = object_key if respond_to?(:object_key)
    transaction.source_name = object_name if respond_to?(:object_name)
    transaction.balance = compute_balance(transaction)
    transaction.save
  end

  def handle_splits(transaction)
    return if transaction.amount.negative?

    all_splits = user.splits + splits
    all_splits.each do |split|
      handle_split(transaction, split)
    end
  end

  def request_handler
    respond_to?(:url) ? self : user.servers.sample
  end

  def handle_split(transaction, split)
    amount = -1 * (split.percent / 100.0 * transaction.amount).round
    RezzableSlRequest.send_money(request_handler,
                                 split.target_name,
                                 amount * -1)
    add_transaction_to_user(transaction, split, amount)
    target = User.find_by_avatar_key(split.target_key)
    add_transaction_to_target(target, amount) if target
  end

  def compute_balance(transaction)
    current_balance = user.transactions.last.nil? ? 0 : user.balance
    transaction.balance = current_balance + transaction.amount
  end

  def add_transaction_to_user(transaction, split, amount)
    current_balance = user.transactions.last.nil? ? 0 : user.balance
    Analyzable::Transaction.create(
      description: "Split from transaction #{transaction.id}",
      amount: amount,
      # source_type: 'system',
      category: 'share',
      user_id: user.id,
      target_name: split.target_name,
      target_key: split.target_key,
      transaction_id: transaction.id,
      balance: current_balance + amount,
      previous_balance: user.transactions.last.balance
    )
  end

  def add_transaction_to_target(target, amount)
    balance = target.balance + (amount * -1)
    Analyzable::Transaction.new(
      user_id: target.id,
      description: "Split from transaction with #{user.avatar_name}",
      amount: amount,
      source_type: 'system',
      category: 'share',
      target_name: user.avatar_name,
      target_key: user.avatar_key,
      balance: balance,
      previous_balance: target.transactions.last.balance
    ).save
  end

  def self.included(base); end
end
