require 'rails_helper'

RSpec.describe Rezzable::WebObject, type: :model do
  it { should act_as AbstractWebObject }
end
