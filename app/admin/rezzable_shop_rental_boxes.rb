ActiveAdmin.register Rezzable::ShopRentalBox, as: 'Shop Rentals' do
  
  include ActiveAdmin::RezzableBehavior
  
  
  menu label: 'Shop Rentals'

  actions :all, except: %i[new create]
  
  decorate_with Rezzable::ShopRentalBoxDecorator
  
  index title: 'Shop Rentals' do
    selectable_column
    column 'Object Name', sortable: :object_name do |traffic_cop|
      link_to traffic_cop.object_name, admin_shop_rental_path(traffic_cop)
    end
    column 'Description', sortable: :description do |traffic_cop|
      truncate(traffic_cop.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |traffic_cop|
      link_to traffic_cop.server.object_name,
              admin_server_path(traffic_cop.server) if traffic_cop.server
    end
    column 'Owner', sortable: 'users.avatar_name' do |traffic_cop|
      if traffic_cop.user
        link_to traffic_cop.user.avatar_name, admin_user_path(traffic_cop.user)
      else
        'Orphan'
      end
    end
    column :weekly_rent
    column :allowed_land_impact
    column :current_land_impact
    column :current_state
    column 'Renter', sortable: :renter_name do |shop_rental|
      shop_rental.renter_name
    end
    column :expiration_date
    
    actions
    
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
      row 'State' do |shop|
        shop.current_state
      end
      row 'Current Renter' do |shop|
        shop.renter_name.nil? ? 'Empty' : shop.renter_name
      end
      row :expiration_date
      row :area
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

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id, :transactions_count, :weekly_rent, :allowed_land_impact, :current_land_impact, :expiration_date, :renter_name, :renter_key, :current_state
  #
  # or
  #
  # permit_params do
  #   permitted = [:object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id, :transactions_count, :weekly_rent, :allowed_land_impact, :current_land_impact, :expiration_date, :renter_name, :renter_key, :current_state]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
