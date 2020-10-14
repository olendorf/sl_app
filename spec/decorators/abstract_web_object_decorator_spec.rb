# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AbstractWebObjectDecorator do
  describe :slurl do
    let(:web_object) do
      FactoryBot.build :abstract_web_object,
                       region: 'Foo Man Choo',
                       position: { x: 10.1, y: 20.32, z: 30.252 }.to_json
    end

    it 'returns the correct url' do
      expect(web_object.decorate.slurl).to eq(
        '<a href="https://maps.secondlife.com/secondlife/' \
        'Foo Man Choo/10/20/30/">Foo Man Choo (10, 20, 30)</a>'
      )
    end
  end
end
