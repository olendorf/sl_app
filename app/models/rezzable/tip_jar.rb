# frozen_string_literal: true

module Rezzable
  class TipJar < ApplicationRecord
    acts_as :abstract_web_object
    
    attr_accessor :session
    
    before_update :handle_session, if: :session?
    
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
    
      def session?
        !self.session.nil?
      end
    
      def handle_session
        check_access
        data = session
        self.session = nil
        self.sessions << Analyzable::Session.new(data)
      end
      
      def check_access
        return true unless self.access_mode_list?
        raise Pundit::NotAuthorizedError if self.allowed_list.
                              where(avatar_key: session['avatar_key']).size.zero?
      end
  end
end
