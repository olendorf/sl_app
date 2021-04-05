require 'rails_helper'

RSpec.describe Analyzable::Detection, type: :model do
  it { should belong_to(:visit).class_name('Analyzable::Visit') }
end
