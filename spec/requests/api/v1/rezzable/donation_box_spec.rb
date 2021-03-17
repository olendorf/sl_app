require 'rails_helper'

RSpec.describe "Api::V1::Rezzable::DonationBoxes", type: :request do
  it_behaves_like 'a user object API', :donation_box
end
