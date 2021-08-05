require 'rails_helper'

RSpec.describe Rezzable::ParcelBox, type: :model do
  it_behaves_like 'a rezzable object', :parcel_box, 1

  it { should respond_to :abstract_web_object }
  it { should belong_to(:parcel).class_name('Analyzable::Parcel') }
end
