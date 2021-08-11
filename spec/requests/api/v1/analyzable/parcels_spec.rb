# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Analyzable::Parcels', type: :request do
  # describe 'GET /index' do
  #   pending "add some examples (or delete) #{__FILE__}"
  # end
  
  let(:user) { FactoryBot.create active_user }
  let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id, region: 'foo' }
  
  describe 'creating a parcel' do 
    
  end
end
