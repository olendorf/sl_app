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

def give_splits(target, avatars)
  total = 100
  rand(1..3).times do
    percent = rand(1..total * 0.75)
    total -= percent
    avatar = avatars.sample
    target.splits << FactoryBot.build(
      :split, percent: percent, target_name: avatar.avatar_name, target_key: avatar.avatar_key
    )
  end
end

def give_terminals(user, avatars)
  rand(3..10).times do
    terminal = FactoryBot.build(:terminal)
    user.web_objects << terminal
    give_splits(terminal, avatars)
    if rand > 0.1 && user.servers.size.positive?
      terminal.server_id = user.servers.sample.id
      terminal.save
    end
  end
end

def give_servers_to_user(user)
  rand(1..10).times do
    server = FactoryBot.create(:server, user_id: user.id)
    rand(1..50).times do
      server.inventories << FactoryBot.build(:inventory)
    end
  end
end

# rubocop:disable Metrics/AbcSize
def give_transactions_to_user(user, avatars)
  num = rand(10..100)
  dates = Array.new(num) { rand(1.year.ago.to_f..Time.now.to_f) }.sort

  sources = %i[donation_boxes web]
  sources += [:terminals] if user.can_be_owner?

  dates.each do |date|
    target = avatars.sample
    source_type = sources.sample
    case source_type
    when :web
      user.transactions << FactoryBot.build(:transaction, source_type: 'Web',
                                                          source_key: user.avatar_key,
                                                          source_name: user.avatar_key,
                                                          target_name: target.avatar_name,
                                                          created_at: Time.at(date))
    when :donation_boxes
      source = user.send(source_type).sample
      source.transactions << FactoryBot.build(:donation, target_key: target.avatar_key,
                                                         target_name: target.avatar_name,
                                                         created_at: Time.at(date))
    when :terminals
      source = user.send(source_type).sample
      amount = rand(1..6) * 300
      source.transactions << FactoryBot.build(:transaction, amount: amount,
                                                            target_key: target.avatar_key,
                                                            target_name: target.avatar_name,
                                                            created_at: Time.at(date))
    end
  end
end
# rubocop:enable Metrics/AbcSize

def give_donation_boxes_to_user(user, avatars)
  rand(1..10).times do
    donation_box = FactoryBot.create(:donation_box, user_id: user.id)
    rand(1..50).times do
      target = avatars.sample
      donation_box.transactions << FactoryBot.build(
        :donation, target_key: target.avatar_key,
                   target_name: target.avatar_name
      )
    end
  end
end

puts 'creating owner'
owner = FactoryBot.create :owner, avatar_name: 'Random Citizen'

avatars = FactoryBot.create_list(:avatar, 1000)

puts 'giving splits to owner'
give_splits(owner, avatars)

puts 'giving servers to owner'
give_servers_to_user(owner)

puts 'giving terminals to owner'
give_terminals(owner, avatars)

puts 'giving donation_boxes to owner'
give_donation_boxes_to_user(owner, avatars)

puts 'giving transactions to owner'
give_transactions_to_user(owner, avatars)

4.times do |i|
  FactoryBot.create :admin, avatar_name: "Admin_#{i} Resident"
end

puts 'creating users'
100.times do |i|
  puts "creating user #{i}"
  user = FactoryBot.create :active_user, avatar_name: "User_#{i} Resident"

  puts "giving splits to user #{i}"
  give_splits(user, avatars)

  puts "giving servers to user #{i}"
  give_servers_to_user(user)

  puts "giving donation_boxes to user #{i}"
  give_donation_boxes_to_user(user, avatars)

  puts "giving transactions to user #{i}"
  give_transactions_to_user(user, avatars)
end

20.times do |i|
  user = FactoryBot.create :inactive_user, avatar_name: "User_#{i + 100} Resident"

  rand(0..4).times do
    user.web_objects << FactoryBot.build(:web_object)
  end
end
