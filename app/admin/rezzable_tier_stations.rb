# frozen_string_literal: true

ActiveAdmin.register Rezzable::TierStation, as: 'Tier Station' do
  include ActiveAdmin::RezzableBehavior

  menu label: 'Tier Stations'

  actions :all, except: %i[new create]

  decorate_with Rezzable::TierStationDecorator

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  filter :abstract_web_object_create_at, as: :date_range, label: 'Date Created'

  index title: 'Tier Stations' do
    selectable_column
    column 'Object Name', sortable: :object_name do |tier_station|
      link_to tier_station.object_name, admin_tier_station_path(tier_station)
    end
    column 'Description' do |tier_station|
      truncate(tier_station.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |tier_station|
      link_to tier_station.server.object_name,
              admin_server_path(tier_station.server) if tier_station.server
    end

    column 'Owner', sortable: 'users.avatar_name' do |tier_station|
      if tier_station.user
        link_to tier_station.user.avatar_name, admin_user_path(tier_station.user)
      else
        'Orphan'
      end
    end
    column 'Version', &:semantic_version
    column :status, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end

  show title: :object_name do
    attributes_table do
      row 'Image' do |tier_station|
        if tier_station.image_key
          image_tag "http://secondlife.com/app/image/#{tier_station.image_key}/1"
        else
          image_tag 'no_image_available'
        end
      end
      row :object_name, &:object_name
      row :object_key, &:object_key
      row :description
      row 'Owner', sortable: 'users.avatar_name' do |tier_station|
        if tier_station.user
          link_to tier_station.user.avatar_name, admin_user_path(tier_station.user)
        else
          'Orphan'
        end
      end
      row 'Server' do |tier_station|
        if tier_station.server
          link_to tier_station.server.object_name, admin_server_path(tier_station.server)
        else
          ''
        end
      end
      row :location, &:slurl
      row 'Sales' do |tier_station|
        "#{tier_station.revenue} $L (#{tier_station.transactions_count} sales)"
      end
      row :created_at
      row :updated_at
      row :pinged_at
      row :version, &:semantic_version
      row :status, &:pretty_active
    end

  end


  permit_params :object_name, :description, :server_id

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      div class: 'alert' do
        h1 'Only change the server OR inventory. Changing both will result in errors.'
      end
      f.input :object_name, label: 'Vendor name'
      f.input :description
      f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
        [s.object_name, s.actable.id]
      }
    end
    f.actions
  end

  controller do
    # def scoped_collection
    #   super.includes(%i[user])
    # end
  end
end
