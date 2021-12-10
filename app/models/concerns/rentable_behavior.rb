# frozen_string_literal: true

# Shared methods for rezzable models
module RentableBehavior
  extend ActiveSupport::Concern

  include ActionView::Helpers::DateHelper

  included do
    has_many :states, as: :rentable, dependent: :destroy,
                      after_add: :set_current_state,
                      class_name: 'Analyzable::RentalState'
  end

  def time_left
    distance_of_time_in_words(Time.current, expiration_date)
  end

  # rubocop:disable Naming/AccessorMethodName
  def set_current_state(state)
    update_column(:current_state, state.state)
    # self.current_state = state.state
  end
  # rubocop:enable Naming/AccessorMethodName

  def add_state(state)
    states.last.update(closed_at: Time.current) if states.size.positive?
    states << Analyzable::RentalState.new(state: state, user_id: user_id)
    update(current_state: state)
  end

  def evict_renter(server, eviction_state)
    MessageUserWorker.perform_async(
      server.id,
      renter_name,
      renter_name,
      I18n.t('analyzable.parcel.eviction', region_name: region)
    )
    states << Analyzable::RentalState.new(
      state: eviction_state,
      user_id: user.id
    )
    update_column(:renter_name, nil)
    update_column(:renter_key, nil)
    update_column(:expiration_date, nil)
  end

  class_methods do
    def process_rentals(class_name, eviction_state)
      rentals = class_name.constantize.where('expiration_date <= ?', 3.days.from_now)
      rentals.each do |rental|
        server = rental.user.servers.sample
        if rental.expiration_date < 3.days.from_now && rental.expiration_date > Time.current
          remind_renter(rental, server)
        elsif rental.expiration_date < Time.current && rental.expiration_date > 3.days.ago
          warn_renter(rental, server)
        else
          rental.evict_renter(server, eviction_state)
        end
      end
    end

    def remind_renter(rental, server)
      MessageUserWorker.perform_async(
        server.id,
        rental.renter_name,
        rental.renter_key,
        I18n.t('analyzable.parcel.reminder',
               region_name: rental.region,
               renter_name: rental.renter_name,
               time: rental.time_left,
               slurl: rental.user.visit_us_slurl)
      )
    end

    def warn_renter(rental, server)
      MessageUserWorker.perform_async(
        server.id,
        rental.renter_name,
        rental.renter_key,
        I18n.t('analyzable.parcel.warning',
               region_name: rental.region,
               renter_name: rental.renter_name,
               time: rental.time_left,
               slurl: rental.user.visit_us_slurl)
      )
    end
  end
end
