require 'rails_helper'

RSpec.describe "Api::V1::Rezzable::ParcelBoxes", type: :request do
  it_behaves_like 'a user object API', :parcel_box
end
