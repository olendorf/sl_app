require 'rails_helper'

RSpec.describe Api::V1::Rezzable::ServiceBoardPolicy, type: :policy do
  it_behaves_like 'it has a rezzable policy', :service_board
end
