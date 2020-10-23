# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OwnerObjectPolicy, type: :policy do
  it_behaves_like 'it has an owner object policy', :terminal
end
