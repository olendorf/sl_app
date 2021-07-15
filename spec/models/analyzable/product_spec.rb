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
  let(:product) { FactoryBot.create :product }

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
end
