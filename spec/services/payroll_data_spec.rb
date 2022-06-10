# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopData do
  let(:user) { FactoryBot.create :active_user }

  before(:each) do
    5.times do
      user.employees << FactoryBot.create(:employee)

      10.times do
        created_at = rand(1.month.ago..Time.current)
        stopped_at = created_at + 2.hours

        user.employees.last.work_sessions << Analyzable::WorkSession.new(
          created_at: created_at,
          stopped_at: stopped_at,
          duration: 2.0
        )
      end
    end
  end

  describe '#payroll_timeline' do
    it 'should return the data' do
      data = PayrollData.payroll_timeline(user)
      expect(data).to include(:dates, :hours, :payments)
      expect(data[:dates].size).to eq 2
      expect(data[:hours].size).to eq 2
      expect(data[:payments].size).to eq 2
    end
  end

  describe '#hours_heatmap' do
    it 'should return the data' do
      data = PayrollData.hours_heatmap(user)
      expect(data.size).to eq 168
    end
  end

  describe '#payment_heatmap' do
    it 'should return the data' do
      data = PayrollData.payment_heatmap(user)
      expect(data.size).to eq 168
    end
  end
end
