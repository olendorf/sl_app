# frozen_string_literal: true

require 'rails_helper'

Sidekiq::Testing.fake!

RSpec.describe 'Api::V1::Rezzable::ShopRentalBoxes', type: :request do
  it_behaves_like 'a user object API', :shop_rental_box

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:rental_box) {
    FactoryBot.create :shop_rental_box,
                      user_id: user.id,
                      server_id: server.id
  }
  let(:renter) { FactoryBot.build :avatar }

  describe 'unrented box is rented' do
    let(:atts) {
      {
        rent_payment: rental_box.weekly_rent * 3,
        target_name: renter.avatar_name,
        target_key: renter.avatar_key
      }
    }

    it 'should return ok status' do
      put api_rezzable_shop_rental_box_path(rental_box),
          params: atts.to_json, headers: headers(rental_box)
      expect(response.status).to eq 200
    end

    it 'should extend the renatl period' do
      put api_rezzable_shop_rental_box_path(rental_box),
          params: atts.to_json, headers: headers(rental_box)
      expect(rental_box.reload.expiration_date).to be_within(2.hours).of(3.weeks.from_now)
    end

    it 'should add the renters info to the box' do
      put api_rezzable_shop_rental_box_path(rental_box),
          params: atts.to_json, headers: headers(rental_box)
      expect(rental_box.reload.renter_name).to eq renter.avatar_name
      expect(rental_box.reload.renter_key).to eq renter.avatar_key
    end
  end

  describe 'rental payment made on rented box' do
    before(:each) do
      rental_box.update(
        renter_name: renter.avatar_name,
        renter_key: renter.avatar_key,
        expiration_date: 1.week.from_now
      )
    end

    let(:atts) {
      { rent_payment: rental_box.weekly_rent * 2 }
    }

    it 'should return ok status' do
      put api_rezzable_shop_rental_box_path(rental_box),
          params: atts.to_json, headers: headers(rental_box)
      expect(response.status).to eq 200
    end

    it 'should update the rental period' do
      put api_rezzable_shop_rental_box_path(rental_box),
          params: atts.to_json, headers: headers(rental_box)
      expect(rental_box.reload.expiration_date).to be_within(2.hours).of(3.weeks.from_now)
    end
  end

  describe 'updating current_land_impact' do
    let(:uri_regex) do
      %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
         auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
    end
    context 'renter is under allotment' do
      let(:atts) { { new_land_impact: rental_box.allowed_land_impact } }
      it 'should return ok status' do
        put api_rezzable_shop_rental_box_path(rental_box),
            params: atts.to_json, headers: headers(rental_box)
        expect(response.status).to eq 200
      end

      it 'should not message the renter' do
        put api_rezzable_shop_rental_box_path(rental_box),
            params: atts.to_json, headers: headers(rental_box)
        expect(@stub).to_not have_been_requested
      end
    end

    context 'renter is over allotment' do
      let(:atts) { { new_land_impact: rental_box.allowed_land_impact + 1 } }

      before(:each) do
        @stub = stub_request(:post, uri_regex)
      end

      it 'should return OK status' do
        put api_rezzable_shop_rental_box_path(rental_box),
            params: atts.to_json, headers: headers(rental_box)
        expect(response.status).to eq 200
      end

      it 'send the a message to the suer' do
        expect {
          put api_rezzable_shop_rental_box_path(rental_box),
              params: atts.to_json, headers: headers(rental_box)
        }.to change { MessageUserWorker.jobs.size }.by(1)
        # expect(@stub).to have_been_requested
      end
    end
  end
end
