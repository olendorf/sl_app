# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::TierStations', type: :request do
  it_behaves_like 'a user object API', :tier_station
end
