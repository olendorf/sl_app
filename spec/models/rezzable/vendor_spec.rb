require 'rails_helper'

RSpec.describe Rezzable::Vendor, type: :model do
  it_behaves_like 'a rezzable object', :vendor, 1
  it_behaves_like 'it is a transactable', :vendor
  
  it { should respond_to :abstract_web_object }
  
  
  
end
