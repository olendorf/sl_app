# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Rezzable::ShopRentalBoxPolicy, type: :policy do
  it_behaves_like 'it has a rezzable policy', :shop_rental_box
end
