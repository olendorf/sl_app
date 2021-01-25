# frozen_string_literal: true

# This file should contain all the record creation needed to seed the
# database with its default values. The data can then be loaded with
# the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# User.create!(
#               email: 'admin@example.com', password: 'password',
#               password_confirmation: 'password') if Rails.env.development?

DatabaseCleaner.clean_with :truncation if Rails.env.development?

owner = FactoryBot.create :owner, avatar_name: 'Random Citizen'

avatars = FactoryBot.create_list(:avatar, 1000)

rand(3..10).times do
  owner.web_objects << FactoryBot.build(:terminal)
end

num = rand(10..20)
dates = Array.new(num) { rand(1.year.ago.to_f..Time.now.to_f) }.sort

dates.each do |date|
  target = avatars.sample
  source = rand < 0.25 ? nil : owner.web_objects.sample
  if source
    owner.transactions << FactoryBot.build(:transaction, source_type: 'SL',
                                                         source_key: source.object_key,
                                                         source_name: source.object_name,
                                                         target_key: target.avatar_key,
                                                         target_name: target.avatar_name,
                                                         created_at: Time.at(date))
  else
    owner.transactions << FactoryBot.build(:transaction, source_type: 'Web',
                                                         source_key: owner.avatar_key,
                                                         source_name: owner.avatar_key,
                                                         target_name: target.avatar_name,
                                                         created_at: Time.at(date))
  end
end

FactoryBot.create :user, avatar_name: 'User Resident'

4.times do |i|
  FactoryBot.create :admin, avatar_name: "Admin_#{i} Resident"
end

100.times do |i|
  user = FactoryBot.create :user, avatar_name: "User_#{i} Resident"

  rand(0..10).times do
    user.web_objects << FactoryBot.build(:web_object)
  end
end
