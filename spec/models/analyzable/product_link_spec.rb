# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::ProductLink, type: :model do
  it { should belong_to :product }
end
