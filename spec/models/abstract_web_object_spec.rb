require 'rails_helper'

RSpec.describe AbstractWebObject, type: :model do
  it { should respond_to :api_key }
  # it { should belong_to(:user) }
  # it { should have_many(:transactions).dependent(:nullify) }
  # it { should belong_to(:server) }

  it { should validate_presence_of :object_name }
  it { should validate_presence_of :object_key }
  it { should validate_presence_of :region }
  it { should validate_presence_of :position }
  it { should validate_presence_of :url }
  
  it { should be_actable }
  
  it { should belong_to :user }
end
