require 'rails_helper'

RSpec.describe Rezzable::TrafficCopDecorator do
  
  let(:traffic_cop) { FactoryBot.build :traffic_cop  }
  
  describe '#pretty_power' do
    context 'power is on' do 
      before(:each) { traffic_cop.power = true}
      it 'returns correct css for on' do 
        traffic_cop.power = :on
        expect(traffic_cop.decorate.pretty_power).to have_css('.status_tag.on', :text => "On")
      end
    end
    
    context 'power is off' do 
      before(:each) { traffic_cop.power = false }
      it 'returns correct css for off' do 
        expect(traffic_cop.decorate.pretty_power).to have_css('.status_tag.off', :text => "Off")
      end
    end
  end
  
  describe '#pretty_sensor_mode' do 
    Rezzable::TrafficCop.sensor_modes.each do |k, v|
      it 'returns the correct content' do 
        traffic_cop.sensor_mode = v
        expect(traffic_cop.decorate.pretty_sensor_mode).to eq k.split('_')[2..-1].join(' ').titleize
      end
    end
  end 
  
  describe '#pretty_security_mode' do 
    Rezzable::TrafficCop.security_modes.each do |k, v|
      it 'returns the correct content' do 
        traffic_cop.security_mode = v
        expect(traffic_cop.decorate.pretty_security_mode).to eq k.split('_')[2..-1].join(' ').titleize
      end
    end
  end 
  
  describe '#pretty_access_mode' do 
    Rezzable::TrafficCop.access_modes.each do |k, v|
      it 'returns the correct content' do 
        traffic_cop.access_mode = v
        expect(traffic_cop.decorate.pretty_access_mode).to eq k.split('_')[2..-1].join(' ').titleize
      end
    end
  end
end
