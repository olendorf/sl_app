# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::RentalState, type: :model do
  it { should belong_to(:rentable) }
  it { should belong_to(:user) }

  it { should define_enum_for(:state).with_values(%i[open for_sale occupied]) }
end
