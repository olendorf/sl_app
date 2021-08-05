# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Parcel, type: :model do
  it { should have_one(:parcel_box).class_name('Rezzable::ParcelBox') }
end
