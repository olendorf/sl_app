# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::WorkSession, type: :model do
  it { should belong_to(:employee).class_name('Analyzable::Employee') }
end
