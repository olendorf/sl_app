require 'rails_helper'

RSpec.describe Analyzable::ParcelState, type: :model do
  it { should belong_to(:parcel).class_name('Analyzable::Parcel') }
  
  it { should define_enum_for(:state).with_values(%i[open for_sale occupied]) }
end
