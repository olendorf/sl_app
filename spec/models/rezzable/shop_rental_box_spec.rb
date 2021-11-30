# frozen_string_literal: true

require 'rails_helper'

Sidekiq::Testing.fake!

RSpec.describe Rezzable::ShopRentalBox, type: :model do
  it_behaves_like 'a rezzable object', :shop_rental_box, 1

  it_behaves_like 'it has rentable behavior', :shop_rental_box

  let(:user) { FactoryBot.create :active_user }
  let(:avatar) { FactoryBot.build :avatar }
  describe 'shop life cycle' do
    let(:shop_box) { FactoryBot.create :shop_rental_box, user_id: user.id }
    context 'rezzing the shop_rental_box' do
      it 'should add the for_rent state' do
        expect(shop_box.states.last.state).to eq 'for_rent'
      end
      it 'should set the current state' do
        expect(shop_box.current_state).to eq 'for_rent'
      end
    end

    context 'shop box is for_rent then rented' do
      before(:each) do
        shop_box.update(
          rent_payment: shop_box.weekly_rent * 3,
          target_name: avatar.avatar_name,
          target_key: avatar.avatar_key
        )
      end
      it 'should add the occupied state' do
        expect(shop_box.states.last.state).to eq 'occupied'
      end

      it 'should set the expiration_date' do
        # shop_box.update(rent_payment: shop_box.weekly_rent * 3)
        expect(shop_box.expiration_date).to be_within(2.hours).of(3.weeks.from_now)
      end

      it 'should add the transaction to the user' do
        # shop_box.update(rent_payment: shop_box.weekly_rent * 3)
        expect(user.reload.transactions.size).to eq 1
      end

      it 'shouild set the renter key and name' do
        # shop_box.update(rent_payment: shop_box.weekly_rent * 3)
        expect(shop_box.renter_name).to eq avatar.avatar_name
        expect(shop_box.renter_key).to eq avatar.avatar_key
      end
    end

    context 'renter renews the rent' do
      before(:each) do
        shop_box.update(
          expiration_date: 1.week.from_now,
          renter_name: avatar.avatar_name,
          renter_key: avatar.avatar_key
        )
        shop_box.update(
          rent_payment: shop_box.weekly_rent * 3,
          target_name: avatar.avatar_name,
          target_key: avatar.avatar_key
        )
      end

      it 'should still be occupied' do
        expect(shop_box.states.last.state).to eq 'occupied'
      end

      it 'should extend the expiration_date' do
        expect(shop_box.expiration_date).to be_within(2.hours).of(4.weeks.from_now)
      end

      it 'should add the transaction to the user' do
        # shop_box.update(rent_payment: shop_box.weekly_rent * 3)
        expect(user.reload.transactions.size).to eq 1
      end

      it 'shouild retain the renter key and name' do
        # shop_box.update(rent_payment: shop_box.weekly_rent * 3)
        expect(shop_box.renter_name).to eq avatar.avatar_name
        expect(shop_box.renter_key).to eq avatar.avatar_key
      end
    end
  end

  describe :check_land_impact do
    let(:uri_regex) do
      %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
         auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
    end
    before(:each) do
      user.web_objects << FactoryBot.build(:server)
      @stub = stub_request(:post, uri_regex)
    end
    context 'land impact not exceeded' do
      it 'should not do anything' do
      end
    end

    context 'land impact exceeded' do
      it 'should send a message to the renter' do
        shop_rental_box = FactoryBot.create :shop_rental_box,
                                            renter_key: avatar.avatar_key,
                                            renter_name: avatar.avatar_name,
                                            allowed_land_impact: 100,
                                            current_land_impact: 101,
                                            user_id: user.id
        shop_rental_box.check_land_impact
        expect(MessageUserWorker).to have_enqueued_sidekiq_job(
          user.servers.last.id, avatar.avatar_name, avatar.avatar_key,
          I18n.t('rezzable.shop_rental_box.land_impact_exceeded',
                 region_name: shop_rental_box.region,
                 allowed_land_impact: shop_rental_box.allowed_land_impact,
                 current_land_impact: shop_rental_box.current_land_impact)
        )
      end
    end
  end
end
