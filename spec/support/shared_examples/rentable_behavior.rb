# frozen_string_literal: true




RSpec.shared_examples 'it has rentable behavior' do |model_name|
  
  Sidekiq::Testing.fake!
  # let(:user) { FactoryBot.create :user }
  # let(:web_object) { FactoryBot.create model_name.to_sym }

  it { should have_many(:states).dependent(:destroy) }
  
  let(:user) { FactoryBot.create :active_user }
  let(:renter) { FactoryBot.build :avatar }
  
  let(:rentable)  { FactoryBot.create model_name.to_sym, user_id: user.id }
  
  describe 'service board life cycle' do 
    
    context "rezzing the shop rental box" do 
      it 'should add the for_rent state' do
        expect(rentable.states.last.state).to eq 'for_rent'
      end
      it 'should set the current state' do
        expect(rentable.current_state).to eq 'for_rent'
      end
    end
    
    context 'shop box is for_rent then rented' do
      before(:each) do
        rentable.update(
          rent_payment: rentable.weekly_rent * 3,
          target_name: renter.avatar_name,
          target_key: renter.avatar_key
        )
      end
      it 'should add the occupied state' do
        expect(rentable.states.last.state).to eq 'occupied'
      end

      it 'should set the expiration_date' do
        # rentable.update(rent_payment: rentable.weekly_rent * 3)
        expect(rentable.expiration_date).to be_within(2.hours).of(3.weeks.from_now)
      end

      it 'should add the transaction to the user' do
        # rentable.update(rent_payment: rentable.weekly_rent * 3)
        expect(user.reload.transactions.size).to eq 1
      end

      it 'shouild set the renter key and name' do
        # rentable.update(rent_payment: rentable.weekly_rent * 3)
        expect(rentable.renter_name).to eq renter.avatar_name
        expect(rentable.renter_key).to eq renter.avatar_key
      end
    end
    
    context 'renter renews the rent' do
      before(:each) do
        rentable.update(
          expiration_date: 1.week.from_now,
          renter_name: renter.avatar_name,
          renter_key: renter.avatar_key
        )
        rentable.update(
          rent_payment: rentable.weekly_rent * 3,
          target_name: renter.avatar_name,
          target_key: renter.avatar_key
        )
      end

      it 'should still be occupied' do
        expect(rentable.states.last.state).to eq 'occupied'
      end

      it 'should extend the expiration_date' do
        expect(rentable.expiration_date).to be_within(2.hours).of(4.weeks.from_now)
      end

      it 'should add the transaction to the user' do
        # rentable.update(rent_payment: rentable.weekly_rent * 3)
        expect(user.reload.transactions.size).to eq 1
      end

      it 'shouild retain the renter key and name' do
        # rentable.update(rent_payment: rentable.weekly_rent * 3)
        expect(rentable.renter_name).to eq renter.avatar_name
        expect(rentable.renter_key).to eq renter.avatar_key
      end
    end
  end
  
  describe '.process_rentals' do
    before(:each) do
      user.web_objects.destroy_all
      user.web_objects << FactoryBot.create(:server)
      2.times do
        renter = FactoryBot.build :avatar
        rentable = FactoryBot.create(model_name.to_sym,
                                     server_id: user.web_objects.first,
                                     renter_name: renter.avatar_name,
                                     renter_key: renter.avatar_key,
                                     expiration_date: 1.week.from_now)
        rentable.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.web_objects << rentable
      end
      3.times do
        renter = FactoryBot.build :avatar
        rentable = FactoryBot.create(model_name.to_sym,
                                     server_id: user.web_objects.first,
                                     renter_name: renter.avatar_name,
                                     renter_key: renter.avatar_key,
                                     expiration_date: 1.day.from_now)
        rentable.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.web_objects << rentable
      end

      5.times do
        renter = FactoryBot.build :avatar
        rentable = FactoryBot.create(model_name.to_sym,
                                     server_id: user.web_objects.first,
                                     renter_name: renter.avatar_name,
                                     renter_key: renter.avatar_key,
                                     expiration_date: 1.day.ago)
        rentable.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.web_objects << rentable
      end
      7.times do
        renter = FactoryBot.build :avatar
        rentable = FactoryBot.create(model_name.to_sym,
                                     server_id: user.web_objects.first,
                                     renter_name: renter.avatar_name,
                                     renter_key: renter.avatar_key,
                                     expiration_date: 4.day.ago)
        rentable.states << Analyzable::RentalState.new(
          user_id: user.id,
          state: 'occupied'
        )
        user.web_objects << rentable
      end
    end
    
    let(:klass) do 
      object = FactoryBot.build(model_name.to_sym)
      object.class
    end

    it 'should message warning to users' do
      expect {
        klass.process_rentals(klass.name, 'for_rent')
      }.to change { MessageUserWorker.jobs.size }.by(15)
    end

    it 'should set the evicted parcels to for_rent' do
      klass.process_rentals(klass.name, 'for_rent')
      expect(user.send(model_name.to_s.pluralize).where(current_state: 'for_rent').size).to eq 7
    end
  end
end
