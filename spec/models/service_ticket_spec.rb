require 'rails_helper'

RSpec.describe ServiceTicket, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :client_key }
  it { should belong_to :user }
  
  it do 
    should define_enum_for(:status).
        with_values(closed: 0, open: 1)
  end
end
