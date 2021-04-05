require 'rails_helper'

RSpec.describe Rezzable::TrafficCop, type: :model do
  it { should respond_to :abstract_web_object }
  
  it { should have_many(:visits).dependent(:destroy).
                                 class_name('Analyzable::Visit') }
  
  it { should define_enum_for(:sensor_mode).with_values(
      sensor_mode_region: 0,
      sensor_mode_parcel: 1,
      sensor_mode_owned_parcels: 2
    )
  }
  
  it { should define_enum_for(:security_mode).with_values(
      security_mode_off: 0,
      security_mode_parcel: 1,
      security_mode_owned_parcels: 2
    )
  }
end
