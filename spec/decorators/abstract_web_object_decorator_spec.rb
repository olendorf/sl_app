# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AbstractWebObjectDecorator do
  let(:web_object) do
    FactoryBot.build :abstract_web_object,
                     region: 'Foo Man Choo',
                     position: { x: 10.1, y: 20.32, z: 30.252 }.to_json
  end

  describe :slurl do
    it 'returns the correct url' do
      expect(web_object.decorate.slurl).to eq(
        '<a href="https://maps.secondlife.com/secondlife/' \
        'Foo Man Choo/10/20/30/">Foo Man Choo (10, 20, 30)</a>'
      )
    end
  end
  
  describe :format_pay_hint do 
    it 'should return hidden if the value is -1' do 
      expect(web_object.decorate.format_pay_hint(-1)).to eq 'Hidden'
    end
    it 'should return default if the value is -2' do 
      expect(web_object.decorate.format_pay_hint(-2)).to eq 'Default'
    end
    it 'should return formtted string if the value is 0 or greater' do 
      expect(web_object.decorate.format_pay_hint(100)).to eq 'L$ 100'
    end
  end

  describe :semantic_version do
    it 'should generate the correct patch version' do
      expect(
        web_object.decorate.semantic_version
      ).to eq "#{web_object.major_version}." +
              "#{web_object.minor_version}." +
              web_object.patch_version.to_s
    end
  end

  describe :pretty_active do
    it 'should return active if it is active' do
      web_object.pinged_at = 1.minute.ago
      expect(web_object.decorate.pretty_active).to eq 'active'
    end

    it 'should return inactive if last ping is stale' do
      web_object.pinged_at = 4.hours.ago
      expect(web_object.decorate.pretty_active).to eq 'inactive'
    end
  end
end
