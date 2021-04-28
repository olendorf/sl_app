require 'rails_helper'

RSpec.describe Rezzable::TipJar, type: :model do
  it { should respond_to :abstract_web_object }
  
  it { 
    should define_enum_for(:access_mode).with_values(
      access_mode_all: 0,
      access_mode_group: 1,
      access_mode_list: 2
      )
  }
end
