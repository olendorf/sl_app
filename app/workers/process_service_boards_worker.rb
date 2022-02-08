# frozen_string_literal: true

# Sets up background process for checking shop rental boxes
# for rental payment status.
class ProcessServiceBoardsWorker
  include Sidekiq::Worker

  def perform(*_args)
    Rezzable::ServiceBoard.process_rentals('Rezzable::ServiceBoard', 'for_rent')
  end
end
