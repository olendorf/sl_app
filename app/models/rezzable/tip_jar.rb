# frozen_string_literal: true

module Rezzable
  # Model for inworld tip jars. Handles tracking sesssions and tips
  class TipJar < ApplicationRecord
    include RezzableBehavior
    include TransactableBehavior

    acts_as :abstract_web_object

    attr_accessor :session, :tip

    before_update :handle_session, if: :session?
    before_update :handle_tip, if: :tip?

    has_many :sessions, as: :sessionable, class_name: 'Analyzable::Session', dependent: :nullify

    has_many :listable_avatars, as: :listable

    OBJECT_WEIGHT = 1

    enum access_mode: {
      access_mode_all: 0,
      access_mode_group: 1,
      access_mode_list: 2
    }

    def allowed_list
      listable_avatars.where(list_name: 'allowed')
    end

    def transaction_category
      'tip'
    end

    def transaction_description(transaction)
      target = current_session.nil? ? 'no target' : current_session.avatar_name
      "Tip from #{transaction.target_name} to #{target}."
    end

    def current_session
      sessions.where(stopped_at: nil).last
    end

    def tip?
      !tip.nil?
    end

    def session?
      !session.nil?
    end

    def handle_session
      check_access
      data = session
      data['user_id'] = user.id
      self.session = nil
      close_session and return if data['avatar_key'].nil?

      sessions << Analyzable::Session.new(data)
    end

    def check_access
      return true unless access_mode_list?
      raise Pundit::NotAuthorizedError if allowed_list
                                          .where(avatar_key: session['avatar_key']).size.zero?
    end

    def close_session
      curr_session = current_session
      duration = (Time.current - curr_session.created_at).seconds
      curr_session.update(duration: duration, stopped_at: Time.current)
    end

    def check_logged_in
      raise ActionController::BadRequest if current_session.nil?
    end

    # rubocop:disable Metrics/AbcSize
    def give_percent(transaction)
      user.reload
      split_amount = ((split_percent / 100.0) * transaction.amount).round
      RezzableSlRequest.send_money(self, current_session.avatar_name, split_amount)
      Analyzable::Transaction.create(
        amount: split_amount * -1,
        category: 'share',
        user_id: user.id,
        transactable_id: id,
        transactable_type: 'Rezzable::TipJar',
        description: "Tip split from #{transaction.target_name} to #{current_session.avatar_name}",
        target_name: current_session.avatar_name,
        target_key: current_session.avatar_key,
        transaction_id: transaction.id,
        balance: calculate_balance(split_amount * -1)
      )
      update_tippee_balance(transaction)
    end
    # rubocop:enable Metrics/AbcSize

    def update_tippee_balance(transaction)
      session_user = User.find_by_avatar_key(current_session.avatar_key)
      return if session_user.nil?

      split_amount = ((split_percent / 100.0) * transaction.amount).round
      session_user.transactions << Analyzable::Transaction.create(
        amount: split_amount,
        source_key: user.avatar_key,
        source_name: user.avatar_name,
        category: 'share',
        description: "Tip split from #{transaction.target_name} from #{user.avatar_name}",
        target_name: user.avatar_name,
        target_key: user.avatar_key,
        balance: calculate_balance(split_amount)
      )
    end

    # rubocop:disable Metrics/AbcSize
    def handle_tip
      data = tip.with_indifferent_access
      self.tip = nil
      raise ActionController::BadRequest if current_session.nil?

      #   puts self.transactions.inspect
      transaction = Analyzable::Transaction.create(
        amount: data['amount'].to_i,
        source_key: current_session.avatar_key,
        source_name: current_session.avatar_name,
        category: 'tip',
        user_id: user.id,
        transactable_id: id,
        transactable_type: 'Rezzable::TipJar',
        description: "Tip from #{data['avatar_name']} to #{current_session.avatar_name}",
        target_name: data['target_name'],
        target_key: data['target_key'],
        balance: calculate_balance(data['amount'].to_i)
      )
      give_percent(transaction)
    end
    # rubocop:enable Metrics/AbcSize

    def calculate_balance(amount)
      current_balance = user.transactions.size.zero? ? 0 : user.transactions.last.balance
      current_balance + amount
    end
  end
end
