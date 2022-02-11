# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceBoardData do
  let(:user) { FactoryBot.create :active_user }

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  before(:each) do
    stub_request(:post, uri_regex)
    server = FactoryBot.create(:server)
    user.web_objects << server
    2.times do
      service_board = FactoryBot.build(
        :service_board,
        expiration_date: 1.week.from_now
      )
      user.web_objects << service_board
    end

    3.times do
      service_board = FactoryBot.build(
        :service_board,
        expiration_date: 1.week.from_now
      )
      user.web_objects << service_board
      avatar = FactoryBot.build :avatar
      4.times do |_i|
        service_board.update(
          rent_payment: service_board.weekly_rent,
          target_key: avatar.avatar_key,
          target_name: avatar.avatar_name
        )
      end
    end

    4.times do
      service_board = FactoryBot.build(
        :service_board,
        expiration_date: 1.week.from_now
      )
      user.web_objects << service_board
      3.times do |_i|
        avatar = FactoryBot.build :avatar
        service_board.update(
          rent_payment: service_board.weekly_rent,
          target_key: avatar.avatar_key,
          target_name: avatar.avatar_name
        )
      end
      service_board.evict_renter(server, 'for_rent')
    end
  end

  describe '#service_board_status_barchart' do
    it 'should return the data' do
      data = ServiceBoardData.service_board_status_barchart(user)
      expect(data).to include :regions, :data
    end
  end

  describe '#service_board_renters' do
    it 'should return the data' do
      expect(ServiceBoardData.service_board_renters(user).size).to eq 3
    end
  end

  describe '#service_board_status_timeline' do
    it 'should return the data' do
      data = ServiceBoardData.service_board_status_timeline(user)
      expect(data[:dates].size).to eq 4
      expect(data[:data][0][:data].size).to eq 4
    end
  end

  describe '#service_board_status_ratio_timeline' do
    it 'should return the data' do
      data = ServiceBoardData.service_board_status_ratio_timeline(user)
      expect(data[:dates].size).to eq 4
      expect(data[:data][0][:data].size).to eq 4
    end
  end

  describe '#region_revenue_bar_chart' do
    it 'should return the data' do
      data = ServiceBoardData.region_revenue_bar_chart(user)
      expect(data[:regions].size).to eq 7
      expect(data[:data].size).to eq 7
    end
  end

  describe '#rental_income_timeline' do
    it 'should return the data' do
      data = ServiceBoardData.rental_income_timeline(user)
      expect(data[:dates].size).to eq 1
      expect(data[:data].size).to eq 7
    end
  end
end
