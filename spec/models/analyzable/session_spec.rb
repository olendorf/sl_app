# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Session, type: :model do
  it { should belong_to(:sessionable) }
end
