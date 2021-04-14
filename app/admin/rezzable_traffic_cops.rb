ActiveAdmin.register Rezzable::TrafficCop, as: 'Traffic Cop' do
  include ActiveAdmin::RezzableBehavior
  
  menu label: 'Traffic Cops'
  
  actions :all, except: %i[new create]
  
  decorate_with Rezzable::TrafficCopDecorator
  
  index title: 'Traffic Cops' do
    selectable_column
    column 'Object Name', sortable: :object_name do |traffic_cop|
      link_to traffic_cop.object_name, admin_traffic_cop_path(traffic_cop)
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
    
    column 'Current Visitors' do |traffic_cop| 
      traffic_cop.current_visitors.size
    end
    
    column 'Recent Visitors' do |traffic_cop|
      traffic_cop.visits.where('stop_time > ?', 1.week.ago).size
    end
    
    column 'Recent Time Spent' do |traffic_cop|
      traffic_cop.visits.where('stop_time > ?', 1.week.ago).sum(:duration)/60
    end
    
    actions
    
  end
  
  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  
  sidebar :settings, only: %i[edit show] do
    attributes_table do
      # row :power
      row 'Power' do |traffic_cop| 
        traffic_cop.pretty_power 
      end
      row 'Sensor mode' do |traffic_cop|
        traffic_cop.pretty_sensor_mode
      end
      row 'Security mode' do |traffic_cop|
        traffic_cop.pretty_security_mode
      end
      row 'Access mode' do |traffic_cop|
        traffic_cop.pretty_access_mode
      end
      row :first_visit_message
      row :repeat_visit_message
      row :inventory_to_give
    end
  end
  
  sidebar :current_visitors do 
    paginated_collection(
      resource.current_visitors.order(duration: :desc).page(
        params[:current_page]
      ).per(10), param_name: 'current_page'
    ) do
      table_for collection, download_links: false do 
        column :avatar_name
        column :start_time
        column 'Duration' do |visit|
          "#{visit.duration/60.0} mins"
        end
      end
    end
  end
  
  sidebar :allowed, only: %i[edit show] do 
    paginated_collection(
      resource.allowed_list.order(:avatar_name).page(
        params[:allowed_page]
      ).per(10), param_name: 'allowed_page'
    ) do 
      table_for collection, download_links: false do 
        column :avatar_name
        column '' do |avatar|
          link_to 'Delete',  admin_listable_avatar_path(avatar), method: :delete, data: {confirm: 'Delete this allowed avatar?' }
        end
      end
    end
  end
  
  sidebar :banned, only: %i[edit show] do 
    paginated_collection(
      resource.banned_list.order(:avatar_name).page(
        params[:allowed_page]
      ).per(10), param_name: 'allowed_page'
    ) do 
      table_for collection, download_links: false do 
        column :avatar_name
        column '' do |avatar|
          link_to 'Delete',  admin_listable_avatar_path(avatar), method: :delete, data: {confirm: 'Unban this avatar?' }
        end
      end
    end
  end
  
  show title: :object_name do 
    attributes_table do 
      row :server_name, &:object_name
      row :server_key, &:object_key
      row :description
      row 'Owner', sortable: 'users.avatar_name' do |server|
        if server.user
          link_to server.user.avatar_name, admin_user_path(server.user)
        else
          'Orphan'
        end
      end
      row :location, &:slurl
      row 'Recent Visitors' do 
        traffic_cop.visits.where('stop_time > ?', 1.week.ago).size
      end
      row 'Recent Time Spent' do  
        traffic_cop.visits.where('stop_time > ?', 1.week.ago).sum(:duration)/60
      end
    end
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id, :power, :sensor_mode, :security_mode, :first_visit_message, :repeat_visit_message, :access_mode, :inventory_to_give
  #
  # or
  #
  # permit_params do
  #   permitted = [:object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id, :power, :sensor_mode, :security_mode, :first_visit_message, :repeat_visit_message, :access_mode, :inventory_to_give]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
