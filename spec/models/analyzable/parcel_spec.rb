# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Parcel, type: :model do
  it { should belong_to(:parcel_box).class_name('Rezzable::ParcelBox') }
  
  let(:user) { FactoryBot.create :active_user }
  
  before(:each) do 
    3.times do 
      FactoryBot.create :parcel, user_id: user.id
    end
    4.times do 
      
      parcel_box = FactoryBot.create :parcel_box, user_id: user.id, region: 'foo'
      FactoryBot.create :parcel, user_id: user.id, region: 'foo', parcel_box_id: parcel_box.id
    end
    # 2.times do |i|
    #   FactoryBot.create :parcel, user_id: user.id, region_name: 'foo', parcel_name: "parcel #{i}"
    # end
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
          FactoryBot.create :parcel, user_id: user.id, region: 'foo', parcel_name: "parcel #{i}"
        end
        
        expect(Analyzable::Parcel.open_parcels(user, 'foo').size).to eq 2
      end
    end
  end
end
