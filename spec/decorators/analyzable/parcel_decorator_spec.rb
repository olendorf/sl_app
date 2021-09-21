# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::ParcelDecorator do
  let(:parcel) do
    FactoryBot.build :parcel,
                     region: 'Foo Man Choo',
                     position: { x: 10.1, y: 20.32, z: 30.252 }.to_json
  end

  describe :slurl do
    it 'returns the correct url' do
      expect(parcel.decorate.slurl).to eq(
        '<a href="https://maps.secondlife.com/secondlife/' \
        'Foo Man Choo/10/20/30/">Foo Man Choo (10, 20, 30)</a>'
      )
    end
  end
end
