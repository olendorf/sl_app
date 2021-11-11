require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should validate_presence_of :text }
  it { should validate_presence_of :author }
  it { should belong_to :service_ticket }
end
