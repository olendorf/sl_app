# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Product, type: :model do
  it { should belong_to :user }
  it { should have_many :product_links }
  it {
    should have_many(:sales).class_name('Analyzable::Transaction')
                            .dependent(:nullify)
  }

  let(:user) { FactoryBot.create :active_user }
  let(:product) { FactoryBot.create :product, user_id: user.id }

  describe 'creation' do
    it 'should set its own name as a product link' do
      new_product = FactoryBot.create(:product)
      expect(new_product.product_links.first.link_name).to eq new_product.product_name
    end
  end

  describe 'updating' do
    it 'should add a new link when the name is changed' do
      product.update(product_name: 'new name')
      expect(product.reload.product_links.last.link_name).to eq 'new name'
    end
  end

  describe '#inventories' do
    before(:each) do
      3.times do
        inv = FactoryBot.create(:inventory,
                                inventory_name: SecureRandom.uuid,
                                user_id: user.id)
        product.product_links << FactoryBot.build(:product_link, link_name: inv.inventory_name)
      end
    end

    it 'should return the inventories' do
      expect(product.inventories.size).to eq 3
    end
  end
end
