# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Visit, type: :model do
  it { should belong_to(:traffic_cop).class_name('Rezzable::TrafficCop') }

  it {
    should have_many(:detections).class_name('Analyzable::Detection')
                                 .dependent(:destroy)
  }

  describe '#active?' do
    it 'should return true if the visit is recent enough' do
      visit = FactoryBot.create :visit
      visit.detections << FactoryBot.build(:detection)
      expect(visit.active?).to be_truthy
    end

    it 'should return false if the visit is to old' do
      visit = FactoryBot.create :visit
      visit.detections << FactoryBot.build(:detection)
      visit.stop_time = Time.now - (3 * Settings.default.traffic_cop.sensor_time)
      visit.save
      expect(visit.active?).to be_falsey
    end
  end

  describe 'adding a detetion' do
    let(:visit) { FactoryBot.create :visit }

    context 'when its a new visit' do
      before(:each) do
        visit.detections << FactoryBot.build(:detection)
      end

      it 'should set the stop time 1/2 the sensor time' do
        expect(visit.stop_time).to be_within(1.second)
          .of(Time.now + (Settings.default.traffic_cop.sensor_time / 2).round)
      end

      it 'should set the duration correctly' do
        expect(visit.duration).to be_within(1.second)
          .of((Settings.default.traffic_cop.sensor_time / 2).round)
      end
    end

    context 'when there are multiple detections' do
      before(:each) do
        visit.start_time = 90.seconds.ago
        visit.detections << FactoryBot.build(:detection)
        visit.detections << FactoryBot.build(:detection)
        visit.detections << FactoryBot.build(:detection)
        visit.detections << FactoryBot.build(:detection)
      end

      it 'should set the stop time 1/2 the sensor time' do
        expect(visit.stop_time).to be_within(1.second)
          .of(Time.now + (Settings.default.traffic_cop.sensor_time / 2).round)
      end

      it 'should set the duration correctly' do
        expect(visit.duration).to be_within(1.second)
          .of(90 + (Settings.default.traffic_cop.sensor_time / 2).round)
      end
    end
  end
end
