require 'rails_helper'

RSpec.describe Rezzable::TierStation, type: :model do
  it_behaves_like 'a rezzable object', :tier_station, 10

  it_behaves_like 'it is a transactable', :tier_station

  it { should respond_to :abstract_web_object }
end
