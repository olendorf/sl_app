# frozen_string_literal: true

require 'rails_helper'

Sidekiq::Testing.fake!

RSpec.describe 'Api::V1::Rezzable::ShopRentalBoxes', type: :request do
  it_behaves_like 'a user object API', :service_board

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:service_board) {
    FactoryBot.create :service_board,
                      user_id: user.id,
                      server_id: server.id
  }
  let(:renter) { FactoryBot.build :avatar }

  describe 'unrented board is rented' do
    let(:atts) {
      {
        rent_payment: service_board.weekly_rent * 3,
        target_name: renter.avatar_name,
        target_key: renter.avatar_key
      }
    }

    it 'should return ok status' do
      put api_rezzable_service_board_path(service_board),
          params: atts.to_json, headers: headers(service_board)
      expect(response.status).to eq 200
    end

    it 'should extend the renatl period' do
      put api_rezzable_service_board_path(service_board),
          params: atts.to_json, headers: headers(service_board)
      expect(service_board.reload.expiration_date).to be_within(2.hours).of(3.weeks.from_now)
    end

    it 'should add the renters info to the box' do
      put api_rezzable_service_board_path(service_board),
          params: atts.to_json, headers: headers(service_board)
      expect(service_board.reload.renter_name).to eq renter.avatar_name
      expect(service_board.reload.renter_key).to eq renter.avatar_key
    end
  end

  describe 'rental payment made on rented box' do
    before(:each) do
      service_board.update(
        renter_name: renter.avatar_name,
        renter_key: renter.avatar_key,
        expiration_date: 1.week.from_now
      )
    end

    let(:atts) {
      { rent_payment: service_board.weekly_rent * 2 }
    }

    it 'should return ok status' do
      put api_rezzable_service_board_path(service_board),
          params: atts.to_json, headers: headers(service_board)
      expect(response.status).to eq 200
    end

    it 'should update the rental period' do
      put api_rezzable_service_board_path(service_board),
          params: atts.to_json, headers: headers(service_board)
      expect(service_board.reload.expiration_date).to be_within(2.hours).of(3.weeks.from_now)
    end
  end

end
