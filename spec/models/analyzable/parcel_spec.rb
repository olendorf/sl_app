# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Parcel, type: :model do
  it { should have_one(:parcel_box).class_name('Rezzable::ParcelBox') }
  it { should belong_to(:user) }
  it { should have_many(:states).class_name('Analyzable::ParcelState').dependent(:destroy) }

  let(:user) { FactoryBot.create :active_user }
  let(:renter) { FactoryBot.build :avatar }

  before(:each) do
    3.times do
      FactoryBot.create :parcel, user_id: user.id
    end
    4.times do
      # parcel_box = FactoryBot.create :parcel_box, user_id: user.id, region: 'foo'
      parcel = FactoryBot.create :parcel, user_id: user.id, region: 'foo'
      parcel.parcel_box = FactoryBot.build(:parcel_box)
    end
    FactoryBot.create :parcel, user_id: user.id, region: 'foo', owner_key: renter.avatar_key,
                               owner_name: renter.avatar_name, expiration_date: 1.week.from_now
  end
  
  # describe 'adding states' do 
  #   let(:parcel)
  #   context 'creating the parcel' do 
  #     it 'should add a for_sale state' do 
        
  #     end
  #   end
  # end
  
  describe 'handling a tier payment' do 
    let(:tier_station) { FactoryBot.create :tier_station, user_id: user.id }

    it 'should update the expiration date' do 
      parcel = user.parcels.find_by_owner_key(renter.avatar_key)
      parcel.update(tier_payment:  (3 * parcel.weekly_tier), requesting_object: tier_station)
      expect(parcel.expiration_date).to be_within(1.second).of(
        4.weeks.from_now
        )
    end
    
    it 'should add the transaction' do 
      parcel = user.parcels.find_by_owner_key(renter.avatar_key)
      parcel.update(tier_payment:  (3 * parcel.weekly_tier), requesting_object: tier_station)
      expect(user.transactions.size).to eq 1
    end
  end
  
  # describe 'parcel is sold' do 
  #   let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id, region: 'foo' }
  #   let(:parcel) { FactoryBot.create :parcel, user_id: user.id, region: 'foo', parcel_box_id: parcel_box.id}
    
  #   it 'should set the experiation date' do 
  #     parcel.states << FactoryBot.build(:state, created_at: 2.days.ago, duration: 1.day, closed_at: 1.day.ago)
  #     parcel.states << FactoryBot.build(:state, state: :for_sale, created_at:.)
  #     parcel.update(owner_key: renter.avatar_key, owner_name: renter.avatar_name)
  #     expect(parcel.expiration_date).to be_within(1.second).of(1.week.from_now)
  #   end
  # end
  
  describe 'handling abandoned parcel' do
  end

  describe '.open_parcels' do
    context 'no open parcels' do
      it 'should return and empty hash' do
        expect(Analyzable::Parcel.open_parcels(user, 'foo').size).to eq 0
      end
    end

    context 'some open parcels' do
      it 'should return the empty parcels' do
        2.times do |i|
          FactoryBot.create :parcel, user_id: user.id, owner_key: nil, region: 'foo', parcel_name: "parcel #{i}"
        end

        expect(Analyzable::Parcel.open_parcels(user, 'foo').size).to eq 2
      end
    end
  end
end
