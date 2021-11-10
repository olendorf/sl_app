# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::ParcelDecorator do
  let(:parcel) do
    FactoryBot.build :parcel,
                     region: 'Foo Man Choo',
                     position: { x: 10.1, y: 20.32, z: 30.252 }.to_json
  end

  describe :slurl do
    it 'returns the correct url' do
      expect(parcel.decorate.slurl).to eq('https://maps.secondlife.com/secondlife/'\
                                          'Foo Man Choo/10/20/30/')
    end
  end

  describe :image_url do
    let(:user) { FactoryBot.create :active_user }
    let(:parcel) { FactoryBot.create :parcel, user_id: user.id }
    context 'there is an image key specified' do
      it 'should return the correct url' do
        parcel.update(image_key: SecureRandom.uuid)
        expect(parcel.decorate.image_url(1)).to eq "http://secondlife.com/app/image/#{parcel.image_key}/1"
      end
    end

    context 'there is a default image specified' do
      it 'should return the correct url' do
        user.update(default_image_key: SecureRandom.uuid)
        expect(parcel.decorate.image_url(1)).to eq "http://secondlife.com/app/image/#{user.default_image_key}/1"
      end
    end

    context 'there is no image specified' do
      it 'should return the correct url' do
        expect(parcel.decorate.image_url(1)).to eq 'no_image_available.jpg'
      end
    end
  end
end
