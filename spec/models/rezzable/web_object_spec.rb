# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::WebObject, type: :model do
  it { should act_as AbstractWebObject }

  let(:user) { FactoryBot.create :active_user }
  let(:object) {
    object = FactoryBot.build :web_object, user_id: user.id
    object.save
    object
  }

  describe 'split_percent' do
    context 'user has no splits' do
      it 'should sum up the splits correctly' do
        object.splits << FactoryBot.build(:split, percent: 10)
        object.splits << FactoryBot.build(:split, percent: 25)
        expect(object.split_percent).to eq 35
      end
    end
    context 'user has splits' do
      it 'should also include user splits' do
        object.splits << FactoryBot.build(:split, percent: 10)
        object.splits << FactoryBot.build(:split, percent: 25)
        user.splits << FactoryBot.build(:split, percent: 5)
        expect(object.split_percent).to eq 40
      end
    end
  end
end
