require 'rails_helper'

RSpec.describe Analyzable::Product, type: :model do
  it { should belong_to :user }
  it { should have_many :product_links }
end
