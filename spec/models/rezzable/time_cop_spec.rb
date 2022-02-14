require 'rails_helper'

RSpec.describe Rezzable::TimeCop, type: :model do
  it_behaves_like 'a rezzable object', :time_cop, 4

  it { should respond_to :abstract_web_object }
end
