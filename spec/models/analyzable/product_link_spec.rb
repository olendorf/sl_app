# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::ProductLink, type: :model do
  it { should belong_to(:product).counter_cache(true) }
  it { should belong_to(:user) }
  it { should validate_uniqueness_of(:link_name).scoped_to(:user_id) }
end
