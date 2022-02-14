# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Employee, type: :model do
  it { should belong_to :user }
  it { should have_many(:work_sessions).class_name('Analyzable::WorkSession') }
end
