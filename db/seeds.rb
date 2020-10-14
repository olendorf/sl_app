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

FactoryBot.create :owner, avatar_name: 'Random Citizen', password: 'password'

FactoryBot.create :user, avatar_name: 'User Resident', password: 'password'

4.times do |i|
  FactoryBot.create :admin, avatar_name: "Admin_#{i} Resident", password: 'password'
end

100.times do |i|
  user = FactoryBot.create :user, avatar_name: "User_#{i} Resident", password: 'password'

  rand(0..10).times do
    user.abstract_web_objects << FactoryBot.build(:web_object)
  end
end
