# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDecorator do
  let(:user) { FactoryBot.create :active_user }
  describe '#business_display_name' do
    context 'user has specified a business name' do
      it 'should return the business name' do
        user.business_name = 'foo'
        expect(user.decorate.business_display_name).to eq 'foo'
      end
    end

    context 'user has not specified a business name' do
      it 'should return the avatar name' do
        expect(user.decorate.business_display_name).to eq user.avatar_name
      end
    end
  end
end
