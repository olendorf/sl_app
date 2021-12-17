# frozen_string_literal: true

require 'rails_helper'

Sidekiq::Testing.fake!

RSpec.describe Rezzable::ShopRentalBox, type: :model do
  it_behaves_like 'a rezzable object', :shop_rental_box, 1
  it_behaves_like 'it has rentable behavior', :shop_rental_box
  it_behaves_like 'it is a transactable', :shop_rental_box

  let(:user) { FactoryBot.create :active_user }
  let(:avatar) { FactoryBot.build :avatar }

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
        shop_rental_box = FactoryBot.create :shop_rental_box,
                                            renter_key: avatar.avatar_key,
                                            renter_name: avatar.avatar_name,
                                            allowed_land_impact: 100,
                                            user_id: user.id
        shop_rental_box.new_land_impact = 100
        shop_rental_box.check_land_impact
        expect(MessageUserWorker).to_not have_enqueued_sidekiq_job(
          user.servers.last.id, avatar.avatar_name, avatar.avatar_key,
          I18n.t('rezzable.shop_rental_box.land_impact_exceeded',
                 region_name: shop_rental_box.region,
                 allowed_land_impact: shop_rental_box.allowed_land_impact,
                 current_land_impact: shop_rental_box.current_land_impact)
        )
      end
    end

    context 'land impact exceeded' do
      it 'should send a message to the renter' do
        shop_rental_box = FactoryBot.create :shop_rental_box,
                                            renter_key: avatar.avatar_key,
                                            renter_name: avatar.avatar_name,
                                            allowed_land_impact: 100,
                                            user_id: user.id
        shop_rental_box.new_land_impact = 101
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

  # describe '.process_rentals' do
  #   before(:each) do
  #     user.web_objects.destroy_all
  #     user.web_objects << FactoryBot.create(:server)
  #     2.times do
  #       renter = FactoryBot.build :avatar
  #       shop_box = FactoryBot.create(:shop_rental_box,
  #                                   server_id: user.web_objects.first,
  #                                   renter_name: renter.avatar_name,
  #                                   renter_key: renter.avatar_key,
  #                                   expiration_date: 1.week.from_now)
  #       shop_box.states << Analyzable::RentalState.new(
  #         user_id: user.id,
  #         state: 'occupied'
  #       )
  #       user.web_objects << shop_box
  #     end
  #     3.times do
  #       renter = FactoryBot.build :avatar
  #       shop_box = FactoryBot.create(:shop_rental_box,
  #                                   server_id: user.web_objects.first,
  #                                   renter_name: renter.avatar_name,
  #                                   renter_key: renter.avatar_key,
  #                                   expiration_date: 1.day.from_now)
  #       shop_box.states << Analyzable::RentalState.new(
  #         user_id: user.id,
  #         state: 'occupied'
  #       )
  #       user.web_objects << shop_box
  #     end

  #     5.times do
  #       renter = FactoryBot.build :avatar
  #       shop_box = FactoryBot.create(:shop_rental_box,
  #                                   server_id: user.web_objects.first,
  #                                   renter_name: renter.avatar_name,
  #                                   renter_key: renter.avatar_key,
  #                                   expiration_date: 1.day.ago)
  #       shop_box.states << Analyzable::RentalState.new(
  #         user_id: user.id,
  #         state: 'occupied'
  #       )
  #       user.web_objects << shop_box
  #     end
  #     7.times do
  #       renter = FactoryBot.build :avatar
  #       shop_box = FactoryBot.create(:shop_rental_box,
  #                                   server_id: user.web_objects.first,
  #                                   renter_name: renter.avatar_name,
  #                                   renter_key: renter.avatar_key,
  #                                   expiration_date: 4.day.ago)
  #       shop_box.states << Analyzable::RentalState.new(
  #         user_id: user.id,
  #         state: 'occupied'
  #       )
  #       user.web_objects << shop_box
  #     end
  #   end

  #   it 'should message warning to users' do
  #     expect {
  #       Rezzable::ShopRentalBox.process_rentals('Rezzable::ShopRentalBox', 'for_rent')
  #     }.to change { MessageUserWorker.jobs.size }.by(15)
  #   end

  #   it 'should set the evicted parcels to for_rent' do
  #     Rezzable::ShopRentalBox.process_rentals('Rezzable::ShopRentalBox', 'for_rent')
  #     puts
  #     expect(user.shop_rental_boxes.where(current_state: 'for_rent').size).to eq 7
  #   end
  # end
end
