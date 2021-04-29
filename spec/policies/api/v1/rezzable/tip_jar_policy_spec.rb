# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Rezzable::TipJarPolicy, type: :policy do
  it_behaves_like 'it has a rezzable policy', :tip_jar
end
