# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Visit, type: :model do
  it { should belong_to(:traffic_cop).class_name('Rezzable::TrafficCop') }

  it {
    should have_many(:detections).class_name('Analyzable::Detection')
                                 .dependent(:destroy)
  }
end
