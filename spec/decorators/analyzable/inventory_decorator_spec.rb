# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::InventoryDecorator do
  describe :pretty_owner_perms do
    context 'copy trans' do
      it 'returns the right text' do
        perms = Analyzable::Inventory::PERMS[:copy] +
                Analyzable::Inventory::PERMS[:transfer]
        inventory = FactoryBot.build :inventory, owner_perms: perms
        expect(
          inventory.decorate.pretty_perms(:owner)
        ).to eq 'Copy|Transfer'
      end
    end

    context 'moidfy' do
      it 'returns the right text' do
        perms = Analyzable::Inventory::PERMS[:modify]
        inventory = FactoryBot.build :inventory, next_perms: perms
        expect(
          inventory.decorate.pretty_perms(:next)
        ).to eq 'Modify'
      end
    end

    context 'copy trans' do
      it 'returns the right text' do
        perms = Analyzable::Inventory::PERMS[:modify] +
                Analyzable::Inventory::PERMS[:transfer]
        inventory = FactoryBot.build :inventory, owner_perms: perms
        expect(
          inventory.decorate.pretty_perms(:owner)
        ).to eq 'Modify|Transfer'
      end
    end
  end

  describe :image_url do
    let(:user) { FactoryBot.create :active_user }
    context 'no image specified' do
      it 'should return no image available ' do
        inventory = FactoryBot.build :inventory
        expect(inventory.decorate.image_url(1)).to eq 'no_image_available.jpg'
      end
    end

    context 'there is a product' do
      it 'should return the correct url' do
        image_key = SecureRandom.uuid
        product = FactoryBot.create(:product, image_key: image_key,
                                              user_id: user.id)
        inventory = FactoryBot.create(:inventory, user_id: user.id)
        FactoryBot.create(
          :product_link,
          product_id: product.id,
          user_id: user.id,
          link_name: inventory.inventory_name
        )
        expect(inventory.decorate.image_url(1)).to eq(
          "http://secondlife.com/app/image/#{image_key}/1"
        )
      end
    end
  end
end
