# frozen_string_literal: true

module Rezzable
  # Model for inworld tip jars. Handles tracking sesssions and tips
  class TipJar < ApplicationRecord
    include RezzableBehavior
    include TransactableBehavior
    include ActionView::Helpers::DateHelper

    acts_as :abstract_web_object

    attr_accessor :session, :tip

    before_update :handle_session, if: :session?
    before_update :handle_tip, if: :tip?

    has_many :sessions, as: :sessionable, class_name: 'Analyzable::Session', dependent: :nullify

    OBJECT_WEIGHT = 1

    enum access_mode: {
      access_mode_all: 0,
      access_mode_group: 1
    }
    
    enum sensor_mode: {
      sensor_mode_off: 0,
      sensor_mode_parcel: 1,
      sensor_mode_region: 3
    }
    
    def response_data
      curr_session = current_session
      self.abstract_web_object.response_data.merge(
        settings: {
          api_key: api_key,
          show_last_tip: show_last_tip,
          show_last_tipper: show_last_tipper,
          show_total: show_total,
          show_duration: show_duration,
          split_percent: split_percent,
          thank_you_message: thank_you_message,
          sensor_mode: sensor_mode,
          show_hover_text: show_hover_text,
          inactive_time: inactive_time,
          access_mode: access_mode
        },
        session: 
          if(!current_session.nil?)
            curr_session.attributes.except("id", "sessionable_id", "sessionable_type", "user_id").merge(
              duration: distance_of_time_in_words(Time.current, curr_session.created_at),
              total: curr_session.transactions.sum(:amount),
              last_tip: curr_session.transactions.last ? curr_session.transactions.last.amount : nil,
              last_tipper: curr_session.transactions.last ? curr_session.transactions.last.target_name : nil,
              last_tipper_key: curr_session.transactions.last ? curr_session.transactions.last.target_key : nil
              )
          else
            nil
          end
      )
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
      
      if current_session
        current_session.update(stopped_at: Time.current)
      end

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
      logger.info "current split percent: #{split_percent}"
      split_percent ||= 100;
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
    end
    
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
      current_session.transactions << transaction
      give_percent(transaction)
    end
    # rubocop:enable Metrics/AbcSize

    def calculate_balance(amount)
      current_balance = user.transactions.size.zero? ? 0 : user.transactions.last.balance
      current_balance + amount
    end
  end
end
