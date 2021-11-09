# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::ProductDecorator do
  describe :image_url do
    let(:user) { FactoryBot.create :active_user }
    let(:product) { FactoryBot.create :product, user_id: user.id }
    context 'there is an image key specified' do
      it 'should return the correct url' do
        product.update(image_key: SecureRandom.uuid)
        expect(product.decorate.image_url(1)).to eq "http://secondlife.com/app/image/#{product.image_key}/1"
      end
    end

    context 'there is a default image specified' do
      it 'should return the correct url' do
        user.update(default_image_key: SecureRandom.uuid)
        expect(product.decorate.image_url(1)).to eq "http://secondlife.com/app/image/#{user.default_image_key}/1"
      end
    end

    context 'there is no image specified' do
      it 'should return the correct url' do
        expect(product.decorate.image_url(1)).to eq 'no_image_available.jpg'
      end
    end
  end
end
