require 'rails_helper'

RSpec.describe Analyzable::Inventory, type: :model do
  it { should validate_presence_of(:inventory_name) }
  it { should validate_presence_of(:inventory_type) }
  it { should validate_presence_of(:owner_perms) }
  it { should validate_presence_of(:next_perms) }
  it { should validate_uniqueness_of(:inventory_name).scoped_to(:server_id) }
  
  it { should belong_to(:user) }
  it { should belong_to(:server) }
end
