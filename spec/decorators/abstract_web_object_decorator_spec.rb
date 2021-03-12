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
