# frozen_string_literal: true

# Sets up background process for checkign parcels for rental status, sending
# appropriate messages and evicting as necessary.
class ProcessParcelsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    Analyzable::Parcel.process_rentals('Analyzable::Parcel', 'open', user.visit_us_slurl)
  end
end
