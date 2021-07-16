# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::TipJarDecorator do
  let(:user) { FactoryBot.create :user }
  let(:tip_jar) { FactoryBot.create :tip_jar, user_id: user.id }
  describe '#time_logged_in' do
    context 'no one is logged in' do
      it 'should return nil' do
        expect(tip_jar.decorate.time_logged_in).to be_nil
      end
    end

    context 'user is logged in' do
      it 'should return the correct time in minutes' do
        tip_jar.sessions << FactoryBot.build(:session, created_at: 1.hour.ago)
        expect(tip_jar.decorate.time_logged_in).to eq 60
      end
    end
  end
end
