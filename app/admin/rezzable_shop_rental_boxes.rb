# frozen_string_literal: true

ActiveAdmin.register Rezzable::ShopRentalBox, as: 'Shop Rental' do
  include ActiveAdmin::RezzableBehavior

  menu label: 'Shop Rentals'

  actions :all, except: %i[new create]

  decorate_with Rezzable::ShopRentalBoxDecorator

  index title: 'Shop Rentals' do
    selectable_column
    column 'Object Name', sortable: :object_name do |shop_rental|
      link_to shop_rental.object_name, admin_shop_rental_path(shop_rental)
    end
    column 'Description', sortable: :description do |shop_rental|
      truncate(shop_rental.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |shop_rental|
      link_to shop_rental.server.object_name,
              admin_server_path(shop_rental.server) if shop_rental.server
    end
    column 'Owner', sortable: 'users.avatar_name' do |shop_rental|
      if shop_rental.user
        link_to shop_rental.user.avatar_name, admin_user_path(shop_rental.user)
      else
        'Orphan'
      end
    end
    column :weekly_rent
    column :allowed_land_impact
    column :current_land_impact
    column :current_state
    column 'Renter', sortable: :renter_name, &:renter_name
    column :expiration_date

    actions defaults: true do |shop_rental|
      link_to 'Evict', evict_admin_shop_rental_path(shop_rental),
              method: :put unless shop_rental.renter_key.nil?
    end
  end

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  filter :allowed_land_impact
  filter :weekly_rent
  filter :expiration_date

  show title: :object_name do
    attributes_table do
      row 'Renter' do |shop|
        link_to shop.user.avatar_name, admin_user_path(shop.user)
      end
      row :description
      row 'State', &:current_state
      row 'Current Renter' do |shop|
        shop.renter_name.nil? ? 'Empty' : shop.renter_name
      end
      row :expiration_date
      row :allowed_land_impact
      row :weekly_rent
      row 'Location', &:slurl
    end

    panel 'Activity' do
      paginated_collection(
        resource.states.order(created_at: :desc).page(
          params[:state_page]
        ).per(10), param_name: 'state_page', download_links: false
      ) do
        table_for collection do
          column 'Event', &:state
          column 'Start', &:created_at
          column 'End', &:closed_at
          column 'Duration' do |state|
            distance_of_time_in_words(state.duration)
          end
        end
      end
    end
  end

  permit_params :object_name, :description,
                :expiration_date, :allowed_land_impact,
                :weekly_rent

  form title: proc { "Edit parcel #{resource.object_name}" } do |f|
    f.inputs do
      f.input :object_name
      f.input :description
      f.input :expiration_date, as: :datetime_picker
      f.input :allowed_land_impact
      f.input :weekly_rent
    end
    f.actions
  end

  member_action :evict, method: :put do
    server = resource.user.servers.sample
    resource.evict_renter(server, 'for_rent')
    redirect_to resource_path, notice: 'Tenant evicted.'
  end

  action_item :evict, only: %i[show edit] do
    link_to 'Evict', evict_admin_shop_rental_path(shop_rental),
            method: :put unless shop_rental.renter_key.nil?
  end

  batch_action :evict do |ids|
    batch_action_collection.find(ids).each do |shop_rental|
      server = shop_rental.user.servers.sample
      shop_rental.evict_renter(server, 'for_rent')
    end
    redirect_to collection_path, alert: 'The users have been evicted.'
  end

  # controller do
  #   # def scoped_collection
  #   #   super.includes(%i[user])
  #   # end
  # end
end
