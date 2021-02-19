require 'rails_helper'

RSpec.describe Api::V1::Rezzable::ServerPolicy, type: :policy do
  it_behaves_like 'it has a rezzable policy', :server
end
