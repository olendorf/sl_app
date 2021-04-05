require 'rails_helper'

RSpec.describe Api::V1::Rezzable::TrafficCopPolicy, type: :policy do
  it_behaves_like 'it has a rezzable policy', :traffic_cop
end
