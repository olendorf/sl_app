# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Split, type: :model do
  it { should belong_to :splittable }

  it {
    should validate_numericality_of(
      :percent
    ).is_less_than_or_equal_to(
      100
    ).is_greater_than(0)
  }
end
