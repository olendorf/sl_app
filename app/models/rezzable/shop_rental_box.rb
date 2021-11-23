class Rezzable::ShopRentalBox < ApplicationRecord
  acts_as :abstract_web_object

  include RezzableBehavior
  include RentableBehavior
  
  after_create -> { add_state('for_rent') }
  before_update :handle_rent_payment, if: :rent_payment
  after_update :check_land_impact, if: :current_land_impact
  
  attr_accessor :rent_payment, :target_name, :target_key
  
  OBJECT_WEIGHT = 1
  
  # def add_for_rent_state
  #   self.states << Analyzable::RentalState.new(state: 'for_rent', user_id: self.user_id)
  # end
  
  def handle_rent_payment
    amount = rent_payment
    self.rent_payment = nil
    add_state('occupied') if self.states.last.state == 'for_rent'
    self.update(expiration_date: Time.current) if self.expiration_date.nil?
    self.update(
                    expiration_date: self.expiration_date + 
                                     (amount.to_f/self.weekly_rent).weeks,
                    renter_name: target_name,
                    renter_key: target_key
    )
    transaction = Analyzable::Transaction.new(
      amount: amount,
      category: 'rent',
      target_name: target_name,
      target_key: target_key
      )
    self.user.transactions << transaction
  end
  
  def check_land_impact
    return unless self.user
    return if self.user.servers.size == 0
    if current_land_impact > allowed_land_impact
      server_id = self.user.servers.sample.id
      MessageUserWorker.perform_async(
        server_id, self.renter_name, self.renter_key,
        I18n.t('rezzable.shop_rental_box.land_impact_exceeded', 
          region_name: self.region, 
          allowed_land_impact: self.allowed_land_impact,
          current_land_impact: self. current_land_impact
        ) ) unless Rails.env.development?
    end
  end
  
  def add_state(state)
    self.states.last.update(closed_at: Time.current) if self.states.size > 0
    self.states << Analyzable::RentalState.new(state: state, user_id: self.user_id)
    self.update(current_state: state)
  end
  
  
end
