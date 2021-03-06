# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListableAvatar, type: :model do
  it { should belong_to :listable }
end
