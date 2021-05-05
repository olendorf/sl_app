module TransactableBehavior
  extend ActiveSupport::Concern
  
  included do 
    has_many :transactions, as: :transactable, 
                            class_name: 'Analyzable::Transaction', 
                            dependent: :nullify,
                            before_add: :handle_attributes,
                            after_add: :handle_splits
    accepts_nested_attributes_for :transactions
  end
  
  # def transaction_category
  #   'other'
  # end

  # def transaction_description(transaction)
  #   "No description given."
  # end

  private

  def source_type
    return 'Web object' if actable.nil?

    actable.model_name.route_key.singularize.split('_')[1..].join('_').humanize
  end

  def handle_attributes(transaction)
    assign_user_to_transaction(transaction)
    transaction.description = transaction_description(transaction)
    transaction.category = transaction_category
    transaction.source_key = object_key
    transaction.source_name = object_name
    transaction.source_type = source_type
    transaction.save
  end

  def assign_user_to_transaction(transaction)
    user.transactions << transaction
  end

  def handle_splits(transaction)
    splits.each do |share|
      user.handle_split(transaction, share)
    end
    server&.splits&.each do |share|
      user.handle_split(transaction, share)
    end
  end
  
  def self.included(base)
  end
end