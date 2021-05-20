# frozen_string_literal: true

module Rezzable
  class TipJar < ApplicationRecord
    acts_as :abstract_web_object
    
    attr_accessor :session, :tip
    
    before_update :handle_session, if: :session?
    # before_update :handle_tip, if: :tip?
    
    include TransactableBehavior
    
    has_many :sessions, as: :sessionable, class_name: 'Analyzable::Session'
    
    has_many :listable_avatars, as: :listable
    
    

    enum access_mode: {
      access_mode_all: 0,
      access_mode_group: 1,
      access_mode_list: 2
    }
    
    def allowed_list
      self.listable_avatars.where(list_name: 'allowed')
    end
    
    def transaction_category
      'tip'
    end

    def transaction_description(transaction)
      target = current_session.nil? ? "no target" : current_session.avatar_name
      "Tip from #{transaction.target_name} to #{target}."
    end
    
    def current_session
      self.sessions.where(stopped_at: nil).last
    end
    
    private 
    
      def tip?
        !self.tip.nil?
      end
    
      def session?
        !self.session.nil?
      end
    
      def handle_session
        check_access
        data = session
        self.session = nil
        close_session and return if data['avatar_key'].nil?

        self.sessions << Analyzable::Session.new(data)
      end
      
      def check_access
        return true unless self.access_mode_list?
        raise Pundit::NotAuthorizedError if self.allowed_list.
                              where(avatar_key: session['avatar_key']).size.zero?
      end
      
      def close_session
        curr_session = current_session
        duration = (Time.current - curr_session.created_at).seconds
        curr_session.update(duration: duration, stopped_at: Time.current)
      end
      
      # overriding app/models/concerns/transactable_behavior.rb
      def handle_splits(transaction)
        raise ActionController::BadRequest if current_session.nil?
        return if transaction.amount.negative?
        
        transaction = give_percent(transaction)
        
        splits.each do |share|
          user.handle_split(transaction, share)
        end
        server&.splits&.each do |share|
          user.handle_split(transaction, share)
        end
      end
      
      def check_logged_in
        raise ActionController::BadRequest if current_session.nil?
      end 
      
      def give_percent(transaction)
        puts "giving user percent"
        user.handle_split( transaction, Split.new(percent: split_percent) )
        transaction.amount = transaction.amount - (split_percent/100.0).round
        transaction
      end
      
      # def handle_tip
      #   puts self.transactions.inspect
      #   data = self.tip
      #   self.tip = nil
      #   puts self.transactions.inspect
      #   raise ActionController::BadRequest if current_session.nil?
        
      #   puts self.transactions.inspect
      #   new_trans = Analyzable::Transaction.new(
      #     amount: data['amount'],
      #     source_key: current_session.avatar_key,
      #     source_name: current_session.avatar_name,
      #     category: 'tip',
      #     description: "Tip from #{data['avatar_name']} to #{current_session.avatar_name}",
      #     target_name: data['avatar_name'],
      #     target_key: data['avatar_key']
      #   )
      #   puts self.inspect
      #   self.transactions << new_trans
      # end
  end
end
