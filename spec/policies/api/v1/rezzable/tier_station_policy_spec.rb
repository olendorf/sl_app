require 'rails_helper'

RSpec.describe Api::V1::Rezzable::TierStationPolicy, type: :policy do
  it_behaves_like 'it has a rezzable policy', :donation_box
end
