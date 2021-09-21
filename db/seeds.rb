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

    # rand(1..50).times do
    # end
  end
end

def give_servers_to_user(user)
  rand(1..10).times do
    server = FactoryBot.create(:server, user_id: user.id)
    rand(1..50).times do
      server.inventories << FactoryBot.build(:sellable_inventory,
                                             inventory_name: SecureRandom.uuid)
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
                                                          category: 'other',
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
    donation_box.server_id = user.servers.sample.id
    donation_box.save
    rand(1..50).times do
      target = avatars.sample
      donation_box.transactions << FactoryBot.build(
        :donation, target_key: target.avatar_key,
                   target_name: target.avatar_name,
                   created_at: Time.at(rand(1.year.ago.to_i..Time.current.to_i))
      )
    end
  end
end

# hash.map { |k,v| [k, v.to_sym] }.to_h
# rubocop:disable Metrics/AbcSize
def give_visits_to_traffic_cop(traffic_cop, avatars, number_of_visits)
  dates = []
  number_of_visits.times { dates << Time.at(rand(1.year.ago.to_i..Time.now.to_i)) }
  dates.sort!
  dates.each do |date|
    avatar = avatars.sample
    visit = FactoryBot.create(:visit, start_time: date,
                                      region: traffic_cop.region,
                                      stop_time: date + 15.seconds,
                                      duration: 15.seconds,
                                      avatar_name: avatar.avatar_name,
                                      avatar_key: avatar.avatar_key,
                                      user_id: traffic_cop.user.id)
    FactoryBot.create(:detection, visit_id: visit.id)
    rand(0..120).times do |_i|
      position = JSON.parse(visit.detections.last.position)
      position['x'] += rand(-5.0..5.0)
      position['x'] = 0 if (position['x']).negative?
      position['x'] = 255 if position['x'] >= 255
      position['y'] += rand(-5.0..5.0)
      position['y'] = 0 if (position['y']).negative?
      position['y'] = 255 if position['y'] >= 255
      position['z'] += rand(-5.0..5.0)
      position['z'] = 0 if (position['x']).negative?
      position['z'] = 4095 if position['x'] >= 4096
      FactoryBot.create(:detection, visit_id: visit.id, position: position.to_json)
      visit.stop_time = visit.stop_time + 30.seconds
      visit.duration = visit.duration + 30
      traffic_cop.visits << visit
    end
  end
end
# rubocop:enable Metrics/AbcSize

def give_traffic_cops_to_user(user, avatars, number_of_visits)
  rand(1..3).times do
    traffic_cop = FactoryBot.create(:traffic_cop)
    user.web_objects << traffic_cop
    traffic_cop.server_id = user.servers.sample.id
    traffic_cop.save
    give_visits_to_traffic_cop(traffic_cop, avatars, number_of_visits)
  end
end

# rubocop:disable Metrics/AbcSize
def give_tips_to_tip_jar(tip_jar, employees, avatars, number_of_tips)
  rand(1..50).times do
    employee = employees.sample
    start_time = Time.at(rand(1.year.ago.to_i..Time.current.to_i))
    duration = rand(1..180)
    stop_time = start_time + duration.minutes
    tip_jar.actable.sessions << FactoryBot.build(:session,
                                                 avatar_name: employee.avatar_name,
                                                 avatar_key: employee.avatar_key,
                                                 created_at: start_time,
                                                 stopped_at: stop_time,
                                                 user_id: tip_jar.user.id,
                                                 duration: duration)
    rand(0..number_of_tips).times do
      tipper = avatars.sample
      FactoryBot.create(:tip, target_name: tipper.avatar_name,
                              target_key: tipper.avatar_key,
                              transactable_id: tip_jar.actable.id,
                              transactable_type: 'Rezzable::TipJar',
                              session_id: tip_jar.actable.sessions.last.id,
                              user_id: tip_jar.user.id,
                              created_at: Time.at(rand(start_time.to_i..stop_time.to_i)))
    end
  end
end
# rubocop:enable Metrics/AbcSize

def give_tip_jars_to_user(user, avatars, number_of_tips)
  employees = FactoryBot.create_list(:avatar, 10)
  rand(1..10).times do
    server = user.servers.sample
    user.web_objects << FactoryBot.build(:tip_jar, server_id: server.id)
    give_tips_to_tip_jar(user.web_objects.last, employees, avatars, number_of_tips)
  end
end

def give_products_to_user(user, number_of_products)
  rand(1..number_of_products).times do |_i|
    user.products << FactoryBot.build(:product)
  end
end

# rubocop:disable Metrics/AbcSize, Metrics/ParameterLists
def give_sales_to_vendor(avatars, vendor, inventory, product, user, number_of_sales)
  rand(1..number_of_sales).times do
    target = avatars.sample
    sale = FactoryBot.create(:sale,
                             amount: inventory.price,
                             transactable_id: vendor.id,
                             transactable_type: 'Rezzable::Vendor',
                             source_name: vendor.object_name,
                             target_name: target.avatar_name,
                             target_key: target.avatar_key,
                             inventory_id: inventory.id,
                             product_id: product.id,
                             created_at: Time.at(rand(1.year.ago.to_i..Time.now.to_i)),
                             user_id: user.id)
    inventory.transactions_count = 0 unless inventory.transactions_count
    product.transactions_count = 0 unless product.transactions_count
    inventory.transactions_count = inventory.transactions_count + 1
    inventory.revenue += sale.amount
    inventory.save
    product.transactions_count = product.transactions_count + 1
    product.revenue += sale.amount
    product.save
    vendor.actable.revenue += sale.amount
    vendor.transactions_count += 1
    vendor.save
  end
end

def give_vendors_to_user(user, avatars, number_of_vendors, number_of_sales)
  rand(1..number_of_vendors).times do
    server = user.servers.sample
    inventory = server.inventories.sample
    server.inventories << inventory
    vendor = FactoryBot.create(:vendor, server_id: server.id,
                                        inventory_name: inventory.inventory_name)
    user.web_objects << vendor
    product = user.products.sample
    product.product_links << FactoryBot.build(
      :product_link, link_name: vendor.inventory_name, user_id: user.id
    )

    give_sales_to_vendor(avatars, vendor, inventory, product, user, number_of_sales)
  end
end

def add_events_to_parcel(parcel)
  # parcel.parcel_box.destroy
  owner = FactoryBot.build :avatar
  event_time = rand(parcel.states.last.created_at..Time.current)
  puts event_time

  previous_state = parcel.states.last

  parcel.update(
    owner_key: owner.avatar_key,
    owner_name: owner.avatar_name
  )

  previous_state.closed_at = event_time
  previous_state.save
  last_state = parcel.states.last
  last_state.created_at = event_time
  last_state.save

  parcel.expiration_date = rand(1..4).weeks.from_now
  parcel.save

  if rand < 0.5
    event_time = rand(parcel.states.last.created_at..Time.current)
    parcel.update(
      owner_key: nil,
      owner_name: nil,
      created_at: event_time
    )

    previous_state = parcel.states[-2]
    previous_state.closed_at = event_time
    previous_state.save
    last_state = parcel.states.last
    last_state.created_at = event_time
    last_state.save
  end
  add_events_to_parcel(parcel) if rand < 0.66
end

def setup_parcel_data_for_user(user, num_tier_stations = 2, num_parcels = 10)
  num_tier_stations.times do |_i|
    user.web_objects << FactoryBot.build(:tier_station)
  end

  num_parcels.times do |_i|
    # parcel = FactoryBot.create(:parcel, user_id: user.id)
    # parcel.states.destroy_all
    parcel_box = FactoryBot.create :parcel_box, user_id: user.id
    user.parcels << FactoryBot.create(:parcel, requesting_object: parcel_box)
    state = user.parcels.last.states.last
    state.created_at = rand(1.year.ago..Time.current)
    state.save

    add_events_to_parcel(user.parcels.last) if rand < 0.66

    # # parcel.parcel_box.destroy
    # owner = FactoryBot.build :avatar
    # event_time = rand(user.parcels.last.states.last.created_at..Time.current)
    # puts event_time

    # previous_state = user.parcels.last.states.last

    # user.parcels.last.update(
    #   owner_key: owner.avatar_key,
    #   owner_name: owner.avatar_name)

    # previous_state.closed_at = event_time
    # previous_state.save
    # last_state = user.parcels.last.states.last
    # last_state.created_at = event_time
    # last_state.save

    # user.parcels.last.expiration_date = rand(1..4).weeks.from_now
    # user.parcels.last.save

    # if rand < 0.5
    #   event_time = rand(user.parcels.last.states.last.created_at..Time.current)
    #   user.parcels.last.update(
    #   owner_key: nil,
    #   owner_name: nil,
    #   created_at: event_time)

    #   previous_state = user.parcels.last.states[-2]
    #   previous_state.closed_at = event_time
    #   previous_state.save
    #   last_state = user.parcels.last.states.last
    #   last_state.created_at = event_time
    #   last_state.save

    # end
    # end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/ParameterLists

puts 'creating owner'
owner = FactoryBot.create :owner, avatar_name: 'Random Citizen'

avatars = FactoryBot.create_list(:avatar, 1000)

puts 'giving splits to owner'
give_splits(owner, avatars)

puts 'giving servers to owner'
give_servers_to_user(owner)

# puts 'giving terminals to owner'
# give_terminals(owner, avatars)

# puts 'giving donation_boxes to owner'
# give_donation_boxes_to_user(owner, avatars)

# puts 'giving transactions to owner'
# give_transactions_to_user(owner, avatars)

# puts 'giving traffic_cops to owner'
# give_traffic_cops_to_user(owner, avatars, 200)

# puts 'giving tip_jars to owner'
# give_tip_jars_to_user(owner, avatars, 20)

puts 'giving vendors to owner'
give_products_to_user(owner, 10)
give_vendors_to_user(owner, avatars, 50, 20)
puts "inv sales: #{owner.vendors.first.inventory.sales.size}"

puts 'setting up land rental system for owner'
setup_parcel_data_for_user(owner)

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

  if rand < 0.5
    puts "giving donation_boxes to user #{i}"
    give_donation_boxes_to_user(user, avatars)

  end

  puts "giving transactions to user #{i}"
  give_transactions_to_user(user, avatars)

  puts "giving traffic_cops to user #{i}"
  give_traffic_cops_to_user(user, avatars, 10) if rand < 0.25

  puts "giving tip_jars to user #{i}"
  give_tip_jars_to_user(user, avatars, 20)

  puts "giving vendors to user #{i}"
  give_products_to_user(user, 10)
  give_vendors_to_user(user, avatars, 20, 10)

  puts "setting up land rental system for user #{i}"
  setup_parcel_data_for_user(user)
end

20.times do |i|
  user = FactoryBot.create :inactive_user, avatar_name: "User_#{i + 100} Resident"

  rand(0..4).times do
    user.web_objects << FactoryBot.build(:web_object)
  end
end
