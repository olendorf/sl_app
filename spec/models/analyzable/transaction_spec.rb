require 'rails_helper'

RSpec.describe Analyzable::Transaction, type: :model do
  
  it { should belong_to :user }
end
