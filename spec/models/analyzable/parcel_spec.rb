# frozen_string_literal: true

require 'rails_helper'

Sidekiq::Testing.fake!

RSpec.describe Analyzable::Parcel, type: :model do
  it_behaves_like 'it has rentable behavior', :parcel

  it { should have_one(:parcel_box).class_name('Rezzable::ParcelBox') }
  it { should belong_to(:user) }
  it { should have_many(:states).dependent(:destroy) }
  it { should have_many(:transactions).class_name('Analyzable::Transaction').dependent(:nullify) }

  let(:user) { FactoryBot.create :active_user }
  let(:renter) { FactoryBot.build :avatar }

  before(:each) do
    3.times do
      FactoryBot.create :parcel, user_id: user.id
    end
    4.times do
      # parcel_box = FactoryBot.create :parcel_box, user_id: user.id, region: 'foo'
      parcel_box = FactoryBot.create(:parcel_box, user_id: user.id)
      FactoryBot.create :parcel, user_id: user.id, region: 'foo', requesting_object: parcel_box
    end
    FactoryBot.create :parcel, user_id: user.id, region: 'foo', renter_key: renter.avatar_key,
                               renter_name: renter.avatar_name, expiration_date: 1.week.from_now
  end

  describe 'parcel life cycle' do
    context 'creating the parcel' do
      let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id }
      before(:each) do
        @parcel = Analyzable::Parcel.create(
          FactoryBot.attributes_for(:parcel, user_id: user.id,
                                             requesting_object: parcel_box)
        )
      end
      it 'should add the parcel box' do
        expect(@parcel.parcel_box.object_key).to eq parcel_box.object_key
      end

      it 'should add the for_sale state' do
        expect(@parcel.states.size).to eq 1
      end

      it 'should be the for_sale state' do
        expect(@parcel.states.last.state).to eq 'for_sale'
      end
    end

    context 'parcel is sold' do
      let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id }
      let(:parcel) { FactoryBot.create :parcel, user_id: user.id, requesting_object: parcel_box }

      it 'should add a state' do
        parcel.update(renter_key: renter.avatar_key, renter_name: renter.avatar_name)
        expect(parcel.states.size).to eq 2
      end

      it 'should add a occupied state' do
        parcel.update(renter_key: renter.avatar_key, renter_name: renter.avatar_name)
        expect(parcel.states.last.state).to eq 'occupied'
      end

      it 'should update the previous state duration and closedat' do
        state = parcel.states.first
        state.created_at = 1.week.ago
        state.save
        parcel.update(renter_key: renter.avatar_key, renter_name: renter.avatar_name)
        expect(parcel.states.first.closed_at).to be_within(10.seconds).of(Time.current)
        expect(parcel.states.first.duration).to be_within(2.hours).of(1.week)
      end

      it 'should remove the parcel box' do
        parcel.update(renter_key: renter.avatar_key, renter_name: renter.avatar_name)
        expect(parcel.reload.parcel_box).to be_nil
      end
    end

    context 'parcel is abandoned' do
      let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id }
      let(:parcel) { FactoryBot.create :parcel, user_id: user.id, requesting_object: parcel_box }

      before(:each) do
        state = parcel.states.first
        state.created_at = 2.weeks.ago
        state.save
        parcel.update(renter_key: renter.avatar_key, renter_name: renter.avatar_name)
        state = parcel.states.last
        state.created_at = 1.week.ago
        state.save
      end

      it 'should add a state' do
        parcel.update(renter_key: nil, renter_name: nil)
        expect(parcel.states.size).to eq 3
      end

      it 'should add an open state' do
        parcel.update(renter_key: nil, renter_name: nil)
        expect(parcel.states.last.state).to eq 'open'
      end

      it 'should update the previous state duration and closed_at' do
        last_state = parcel.states.last
        parcel.update(renter_key: nil, renter_name: nil)
        expect(last_state.reload.closed_at).to be_within(1.second).of(Time.current)
        # allows testing over day light savings things
        expect(last_state.reload.duration).to be_within(2.hours).of(1.week)
      end
    end

    context 'setting out parcel_box ' do
      let(:parcel_box) { FactoryBot.create :parcel_box, user_id: user.id }
      let(:parcel) { FactoryBot.create :parcel, user_id: user.id, requesting_object: parcel_box }
      let(:new_parcel_box) { FactoryBot.create :parcel_box, user_id: user.id }

      before(:each) do
        state = parcel.states.first
        state.created_at = 3.weeks.ago
        state.save
        parcel.update(renter_key: renter.avatar_key, renter_name: renter.avatar_name)
        state = parcel.states.last
        state.created_at = 2.week.ago
        state.save
        parcel.update(renter_key: nil, renter_name: nil)
        state = parcel.states.last
        state.created_at = 1.week.ago
        state.save
      end

      it 'should add the state' do
        parcel.update(parcel_box_key: new_parcel_box.object_key)
        expect(parcel.states.size).to eq 4
      end

      it 'shouuld set the state to for sale' do
        parcel.update(parcel_box_key: new_parcel_box.object_key)
        expect(parcel.states.last.state).to eq 'for_sale'
      end

      it 'should update the previous state duration and closed_at' do
        last_state = parcel.states.last
        parcel.update(parcel_box_key: new_parcel_box.object_key)
        expect(last_state.reload.closed_at).to be_within(2.hours).of(Time.current)
        expect(last_state.reload.duration).to be_within(2.hours).of(1.week)
      end
    end
  end

  describe 'handling a tier payment' do
    let(:tier_station) { FactoryBot.create :tier_station, user_id: user.id }

    it 'should update the expiration date' do
      parcel = user.parcels.find_by_renter_key(renter.avatar_key)
      parcel.update(rent_payment: (3 * parcel.weekly_rent), requesting_object: tier_station)
      # Test fails when the extension spans over daylights savings time shift.
      expect(parcel.expiration_date).to be_within(2.hours).of(
        4.weeks.from_now
      )
    end

    it 'should add the transaction' do
      parcel = user.parcels.find_by_renter_key(renter.avatar_key)
      parcel.update(rent_payment: (3 * parcel.weekly_rent), requesting_object: tier_station)
      expect(user.transactions.size).to eq 1
    end
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
          FactoryBot.create :parcel, user_id: user.id, renter_key: nil, region: 'foo',
                                     parcel_name: "parcel #{i}"
        end

        expect(Analyzable::Parcel.open_parcels(user, 'foo').size).to eq 2
      end
    end
  end
  # trigger a build

  describe '.process_rentals' do
    before(:each) do
      user.parcels.destroy_all  # made some parcels previously that need gone
      user.web_objects << FactoryBot.create(:server)
      2.times do
        renter = FactoryBot.build :avatar
        parcel = FactoryBot.create(:parcel,
                                   expiration_date: 1.week.from_now,
                                   user_id: user.id,
                                   renter_name: renter.avatar_name,
                                   renter_key: renter.avatar_key)
        parcel.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.parcels << parcel
      end
      3.times do
        renter = FactoryBot.build :avatar
        parcel = FactoryBot.create(:parcel,
                                   expiration_date: 1.day.from_now,
                                   user_id: user.id,
                                   renter_name: renter.avatar_name,
                                   renter_key: renter.avatar_key)
        parcel.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.parcels << parcel
      end
      5.times do
        renter = FactoryBot.build :avatar
        parcel = FactoryBot.create(:parcel,
                                   expiration_date: 1.day.ago,
                                   user_id: user.id,
                                   renter_name: renter.avatar_name,
                                   renter_key: renter.avatar_key)
        parcel.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.parcels << parcel
      end
      7.times do
        renter = FactoryBot.build :avatar
        parcel = FactoryBot.create(:parcel,
                                   expiration_date: 4.days.ago,
                                   user_id: user.id,
                                   renter_name: renter.avatar_name,
                                   renter_key: renter.avatar_key)
        parcel.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.parcels << parcel
      end
    end
    it 'should message warning to users' do
      expect {
        Analyzable::Parcel.process_rentals('Analyzable::Parcel', 'open')
      }.to change { MessageUserWorker.jobs.size }.by(15)
    end

    it 'should set the evicted parcels to open' do
      Analyzable::Parcel.process_rentals('Analyzable::Parcel', 'open')
      expect(user.parcels.where(current_state: 'open').size).to eq 7
    end
  end
end
