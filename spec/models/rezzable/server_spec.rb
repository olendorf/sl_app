require 'rails_helper'

RSpec.describe Rezzable::Server, type: :model do
  it { should respond_to :abstract_web_object }
  it { should have_many(:clients).class_name('AbstractWebObject') }
end
