# frozen_string_literal: true

# Sets up background process for checking shop rental boxes
# for rental payment status.
class ProcessShopRentalBoxesWorker
  include Sidekiq::Worker

  def perform(*_args)
    Rezzable::ShopRentalBox.process_rentals('Rezzable::ShopRentalBox', 'for_rent')
  end
end
