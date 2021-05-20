module TransactableBehavior
  extend ActiveSupport::Concern
  
  included do 
    has_many :transactions, as: :transactable, 
                            class_name: 'Analyzable::Transaction', 
                            dependent: :nullify,
                            before_add: :process_transaction,
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
  
  def is_positive?(transaction)
    transaction.amount.positive?
  end

  def source_type
    return 'Web object' if actable.nil?

    actable.model_name.route_key.singularize.split('_')[1..].join('_').humanize
  end
  
  def process_transaction(transaction)
    handle_attributes(transaction)
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
    puts "handlng splits"
    return if transaction.amount.negative?
    puts "still handling splits"
    splits.each do |share|
      puts "handling object splits"
      handle_split(transaction, share)
      puts user.transactions.size
    end
    user.splits&.each do |share|
      puts "handling user splits"
      handle_split(transaction, share)
      puts user.transactions.size
    end
    puts user.transactions.size
  end
  
  def handle_split(transaction, share)
    puts "handling split"
    puts servers.inspect
    # server = servers.sample
    return unless server

    amount = (share.percent / 100.0 * transaction.amount).round
    puts "amount given: #{amount}"
    RezzableSlRequest.send_money(self,
                                  share.target_name,
                                  share.target_key,
                                  amount)
    user.add_transaction_to_user(transaction, amount, share)
    target = User.find_by_avatar_key(share.target_key)
    add_transaction_to_target(target, amount) if target
  end
  
  def self.included(base)
  end
end